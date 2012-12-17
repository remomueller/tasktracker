class Sticky < ActiveRecord::Base
  attr_accessible :description, :project_id, :owner_id, :board_id, :due_date, :group_id, :completed, :duration, :duration_units, :all_day, :tag_ids

  serialize :old_tags, Array # Deprecated however used to migrate from old schema to new tag framework

  # Named Scopes
  scope :current, conditions: { deleted: false }
  scope :with_creator, lambda { |*args|  { conditions: ["stickies.user_id IN (?)", args.first] } }
  scope :with_owner, lambda { |*args|  { conditions: ["stickies.owner_id IN (?) or stickies.owner_id IS NULL", args.first] } }
  scope :with_board, lambda { |*args| { conditions: ["stickies.board_id IN (?) or (stickies.board_id IS NULL and 0 IN (?))", args.first, args.first] } }
  scope :search, lambda { |*args| { conditions: [ 'LOWER(stickies.description) LIKE ? or stickies.group_id IN (select groups.id from groups where LOWER(groups.description) LIKE ?)', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%' ] } }
  scope :updated_since, lambda { |*args| { conditions: ["stickies.updated_at > ?", args.first] }}
  scope :with_date_for_calendar, lambda { |*args| { conditions: ["DATE(stickies.created_at) >= ? and DATE(stickies.created_at) <= ?", args.first, args[1]]}}

  scope :with_due_date_for_calendar, lambda { |*args| { conditions: { due_date: args.first.at_midnight..args[1].end_of_day } } }

  scope :due_date_before, lambda { |*args| { conditions: ["stickies.due_date < ?", (args.first+1.day).at_midnight]} }
  scope :due_date_after, lambda { |*args| { conditions: ["stickies.due_date >= ?", args.first.at_midnight]} }

  scope :due_date_before_or_blank, lambda { |*args| { conditions: ["stickies.due_date < ? or stickies.due_date IS NULL", (args.first+1.day).at_midnight]} }
  scope :due_date_after_or_blank, lambda { |*args| { conditions: ["stickies.due_date >= ? or stickies.due_date IS NULL", args.first.at_midnight]} }

  scope :due_today,     lambda { |*args| { conditions: { completed: false, due_date: Date.today.at_midnight..Date.today.end_of_day } } }
  scope :past_due,      lambda { |*args| { conditions: ["stickies.completed = ? and stickies.due_date < ?", false, Date.today.at_midnight] } }
  scope :due_upcoming,  lambda { |*args| { conditions: ["stickies.completed = ? and stickies.due_date >= ? and stickies.due_date < ?", false, Date.tomorrow.at_midnight, (Date.today.friday? ? Date.tomorrow + 3.days : Date.tomorrow + 1.day).at_midnight]}}
  scope :due_this_week, lambda { |*args| { conditions: { completed: false, due_date: (Date.today - Date.today.wday.days).at_midnight..(Date.today + (6-Date.today.wday).days).end_of_day} } }

  scope :with_tag, lambda { |*args| { conditions: [ "stickies.id IN (SELECT stickies_tags.sticky_id from stickies_tags where stickies_tags.tag_id IN (?))", args.first ] } }

  before_create :set_start_date
  after_create :send_email

  before_save :set_end_date, :set_project_and_board
  # after_save :send_completion_email, :send_due_at_updated

  # Model Validation
  validates_presence_of :description, :project_id

  # Model Relationships
  belongs_to :user
  belongs_to :project, touch: true
  belongs_to :group
  belongs_to :board
  belongs_to :owner, class_name: 'User', foreign_key: 'owner_id'
  has_and_belongs_to_many :tags
  has_many :comments, order: 'created_at desc', conditions: { deleted: false }

  def as_json(options={})
    super(only: [:id, :user_id, :project_id, :completed, :description, :owner_id, :board_id, :due_date, :duration, :duration_units, :all_day, :created_at, :updated_at, :group_id], methods: [:group_description, :sticky_link, :tags])
  end

  def sticky_link
    SITE_URL + "/stickies/#{self.id}"
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

  def due_at_string
    (all_day? ? '' : due_date.localtime.strftime("%l:%M %p").strip) rescue ''
  end

  def due_at_string_short
    self.due_at_string.gsub(':00', '').gsub(' AM', 'a').gsub(' PM', 'p')
  end

  def due_at_end_string
    (all_day? or self.duration <= 0) ? '' : (due_date + self.duration.send(self.duration_units)).localtime.strftime("%l:%M %p").strip
  end

  def due_at_end_string_short
    self.due_at_end_string.gsub(':00', '').gsub(' AM', 'a').gsub(' PM', 'p')
  end

  def due_at_end_string_with_duration
    (all_day? or self.duration <= 0) ? '' : self.due_at_end_string + " (#{self.duration} #{self.duration_units})"
  end

  def due_at_range_short
    self.due_at_string_short + (self.due_at_end_string_short.blank? ? '' : '-' + self.due_at_end_string_short)
  end

  def due_at_range
    self.due_at_string + (self.due_at_end_string.blank? ? '' : ' to ' + self.due_at_end_string)
  end

  def due_at_string=(due_at_str)
  #   self.due_at = Time.parse(due_at_str)
  # rescue
  #   self.due_at = nil
  end

  def due_date_time_end
    self.due_date + self.duration.send(self.duration_units)
  end

  def export_ics
    RiCal.Calendar do |cal|
      self.export_ics_block_evt(cal)
    end.to_s
  end

  def export_ics_block_evt(cal)
    cal.event do |evt|
      evt.summary     = self.full_description.truncate(27)
      evt.description = self.ics_description
      evt.dtstart     = self.due_date.to_date    if self.all_day? and not self.due_date.blank?
      evt.dtstart     = self.due_date            if not self.all_day? and not self.due_date.blank?
      evt.dtend       = self.due_date_time_end   if not self.all_day? and not self.due_date.blank?
      evt.uid         = "#{SITE_URL}/stickies/#{self.id}"
    end
  end

  def include_ics?
    not self.due_date.blank?
  end

  def tag_ids
    self.tags.order('tags.name').pluck('tags.id')
  end

  def name
    "##{self.id}"
  end

  def destroy
    self.comments.destroy_all
    update_column :deleted, true
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

  def ics_description
    result = ''
    result << "To Update Sticky: #{SITE_URL}/stickies/#{self.id}\n\n"
    result << "Status: #{self.completed? ? 'Completed' : 'Not Completed'}\n\n"
    result << "Assigned To: #{self.owner.name}\n\n" if self.owner
    result << "Project: #{self.project.name}\n\n"
    result << self.full_description + "\n\n"
    result << "Tags: #{self.tags.pluck(:name).join(', ')}\n\n" if self.tags.size > 0
    result
  end

  def shift_group(days_to_shift, shift)
    if days_to_shift != 0 and self.group and ['incomplete', 'all'].include?(shift)
      sticky_scope = self.group.stickies.where("stickies.id != ?", self.id)
      sticky_scope = sticky_scope.where(completed: false) if shift == 'incomplete'
      sticky_scope.select{ |s| not s.due_date.blank? }.each{ |s| s.update_attributes due_date: s.due_date + days_to_shift.days }
    end
  end

  def send_email_if_recently_completed(current_user)
    self.send_completion_email(current_user) if self.previous_changes[:completed] and self.previous_changes[:completed][1] == true
  end

  def send_completion_email(current_user)
    all_users = self.project.users_to_email(:sticky_completion) - [current_user]
    all_users.each do |user_to_email|
      UserMailer.sticky_completion_by_mail(self, current_user, user_to_email).deliver if Rails.env.production?
    end
  end

  def self.send_stickies_completion_email(all_stickies, current_user)
    all_stickies.group_by{|s| s.project}.each do |project, stickies|
      all_users = project.users_to_email(:sticky_completion) - [current_user]
      all_users.each do |user_to_email|
        UserMailer.stickies_completion_by_mail(stickies, current_user, user_to_email).deliver if Rails.env.production?
      end
    end
  end

  private

  def send_email
    if not self.group and not self.completed?
      all_users = self.project.users_to_email(:sticky_creation) - [self.user]
      all_users.each do |user_to_email|
        UserMailer.sticky_by_mail(self, user_to_email).deliver if Rails.env.production?
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
