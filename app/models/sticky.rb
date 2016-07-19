class Sticky < ActiveRecord::Base

  before_create :set_start_date
  after_create :send_email
  after_save :clone_repeat
  before_save :set_end_date, :set_project_and_board

  REPEAT = ["none", "day", "week", "month", "year"].collect{|i| [i,i]}

  # Concerns
  include Deletable

  # Named Scopes
  scope :search, lambda { |arg| where('LOWER(stickies.description) LIKE ? or stickies.group_id IN (select groups.id from groups where LOWER(groups.description) LIKE ?)', arg.to_s.downcase.gsub(/^| |$/, '%'), arg.to_s.downcase.gsub(/^| |$/, '%')).references(:groups) }
  scope :with_creator, lambda { |arg|  where( user_id: arg ) }
  scope :with_owner, lambda { |arg|  where("stickies.owner_id IN (?) or stickies.owner_id IS NULL", arg) }
  scope :with_board, lambda { |arg| where("stickies.board_id IN (?) or (stickies.board_id IS NULL and 0 IN (?))", arg, arg) }
  scope :updated_since, lambda { |arg| where("stickies.updated_at > ?", arg) }
  scope :with_date_for_calendar, lambda { |*args| where("DATE(stickies.created_at) >= ? and DATE(stickies.created_at) <= ?", args.first, args[1]) }

  scope :with_due_date_for_calendar, lambda { |*args| where( due_date: args.first..args[1] ) }

  scope :due_date_before, lambda { |arg| where("stickies.due_date < ?", arg+1.day) }
  scope :due_date_after, lambda { |arg| where("stickies.due_date >= ?", arg) }

  scope :due_date_before_or_blank, lambda { |arg| where("stickies.due_date < ? or stickies.due_date IS NULL", arg+1.day) }
  scope :due_date_after_or_blank, lambda { |arg| where("stickies.due_date >= ? or stickies.due_date IS NULL", arg) }

  scope :due_today,     -> { where( completed: false, due_date: Date.today ) }
  scope :past_due,      -> { where("stickies.completed = ? and stickies.due_date < ?", false, Date.today) }
  scope :due_upcoming,  -> { where("stickies.completed = ? and stickies.due_date > ? and stickies.due_date <= ?", false, Date.today, (Date.today.friday? ? Date.tomorrow + 2.days : Date.tomorrow)) }
  scope :due_this_week, -> { where( completed: false, due_date: (Date.today - Date.today.wday.days)..(Date.today + (6-Date.today.wday).days) ) }

  scope :with_tag, lambda { |arg| where("stickies.id IN (SELECT stickies_tags.sticky_id from stickies_tags where stickies_tags.tag_id IN (?))", arg).references(:tags) }

  # Model Validation
  validates_presence_of :description, :project_id
  validates_numericality_of :repeat_amount, only_integer: true, greater_than: 0

  # Model Relationships
  belongs_to :user
  belongs_to :project, touch: true
  belongs_to :group
  belongs_to :board
  belongs_to :owner, class_name: 'User', foreign_key: 'owner_id'
  belongs_to :repeated_sticky, -> { where deleted: false }, class_name: 'Sticky', foreign_key: 'repeated_sticky_id'
  has_and_belongs_to_many :tags
  has_many :comments, -> { where( deleted: false ).order( 'created_at desc' ) }

  def sticky_link
    ENV['website_url'] + "/stickies/#{self.id}"
  end

  # Panel returns 'completed', 'past_due', or 'upcoming'
  # Since both upcoming and past_due incomplete contain stickies
  # with "today's" due date or without a due date, these both get
  # placed into past_due
  def panel
    if self.completed?
      'completed'
    elsif self.due_date and self.due_date.to_date > Date.today
      'upcoming'
    else
      'past_due'
    end
  end

  def modifiable_by?(current_user)
    # current_user.all_projects.pluck(:id).include?(self.project_id)
    self.project_id.blank? or self.project.modifiable_by?(current_user)
  end

  def tag_ids
    self.tags.order('tags.name').pluck('tags.id')
  end

  def name
    "##{self.id}"
  end

  def destroy
    self.comments.destroy_all
    super
  end

  def full_description
    @full_description ||= begin
      if self.group and not self.group.description.blank?
        self.description + "\n\n" + self.group.description
      else
        self.description
      end
    end
  end

  def group_description
    @group_description ||= begin
      (self.group ? self.group.description : nil)
    end
  end

  def description_html
    result = ""
    result << self.full_description + "\n\n"
    result << "<hr class='soften' style='margin-top:5px;margin-bottom:5px'/>"
    result << "<div style='white-space:nowrap'><strong>Assigned</strong> #{self.owner.name} <img alt='' src='#{self.owner.avatar_url(18, "identicon")}' class='img-rounded'></div>" if self.owner
    result << "<strong>Board</strong> #{self.board ? self.board.name : 'Holding Pen'}<br />" if self.project.boards.size > 0
    result << "<strong>Repeats</strong> #{self.repeat_amount} #{self.repeat}#{'s' if self.repeat_amount != 1} after due date<br />" if self.repeat != 'none'
    result
  end

  def shift_group(days_to_shift, shift)
    if days_to_shift != 0 and self.group and ['incomplete', 'all'].include?(shift)
      sticky_scope = self.group.stickies.where("stickies.id != ?", self.id)
      sticky_scope = sticky_scope.where(completed: false) if shift == 'incomplete'
      sticky_scope.select{ |s| not s.due_date.blank? }.each{ |s| s.update due_date: s.due_date + days_to_shift.days }
    end
  end

  def send_email_if_recently_completed(current_user)
    if self.previous_changes[:completed] and self.previous_changes[:completed][1] == true
      self.update(due_date: Date.today) if self.due_date.blank?
      self.send_completion_email(current_user)
    end
  end

  def send_completion_email(current_user)
    all_users = self.project.users_to_email(:sticky_completion) - [current_user]
    all_users.each do |user_to_email|
      UserMailer.sticky_completion_by_mail(self, current_user, user_to_email).deliver_now if EMAILS_ENABLED
    end
  end

  # def self.send_stickies_completion_email(all_stickies, current_user)
  #   all_stickies.group_by{|s| s.project}.each do |project, stickies|
  #     all_users = project.users_to_email(:sticky_completion) - [current_user]
  #     all_users.each do |user_to_email|
  #       UserMailer.stickies_completion_by_mail(stickies, current_user, user_to_email).deliver_now if EMAILS_ENABLED
  #     end
  #   end
  # end

  private

  def clone_repeat
    if self.changes[:completed] and self.changes[:completed][1] == true and self.repeat != 'none' and self.repeated_sticky.blank? and not self.due_date.blank?
      new_sticky = self.user.stickies.new(self.attributes.reject{|key, val| ['id', 'user_id', 'deleted', 'created_at', 'updated_at', 'start_date', 'end_date', 'repeated_sticky_id', 'completed'].include?(key.to_s)})
      new_sticky.due_date += (self.repeat_amount).send(new_sticky.repeat)
      new_sticky.tag_ids = self.tags.pluck(:id)
      new_sticky.save
      self.update_column :repeated_sticky_id, new_sticky.id
    end
  end

  def send_email
    if not self.group and not self.completed?
      all_users = self.project.users_to_email(:sticky_creation) - [self.user]
      all_users.each do |user_to_email|
        UserMailer.sticky_by_mail(self, user_to_email).deliver_now if EMAILS_ENABLED
      end
    end
  end

  def set_start_date
    self.start_date = Date.today
  end

  def set_end_date
    self.end_date = ((self.changes[:completed] and self.changes[:completed][1] == true) ? Date.today : nil) unless self.completed? and self.changes[:completed] == nil
  end

  def set_project_and_board
    if self.group
      self.project_id = self.group.project_id
      if not (self.group.project.boards.pluck(:id) + [nil]).include?(self.board_id) and self.changes[:board_id]
        self.board_id = self.changes[:board_id][0]
      end
    end
  end

end
