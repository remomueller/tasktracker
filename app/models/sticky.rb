class Sticky < ActiveRecord::Base

  STATUS = ["planned", "ongoing", "completed"].collect{|i| [i,i]}
  STICKY_TYPE = ["generic", "action item", "goal", "roadblock"].collect{|i| [i,i]}

  # Named Scopes
  scope :current, :conditions => { :deleted => false }
  scope :status, lambda { |*args|  { :conditions => ["stickies.status IN (?)", args.first] } }
  scope :with_project, lambda { |*args| { :conditions => ["stickies.project_id IN (?) or (stickies.project_id IS NULL and stickies.user_id = ?)", args.first, args[1]] } }
  scope :with_creator, lambda { |*args|  { :conditions => ["stickies.user_id IN (?)", args.first] } }
  scope :with_owner, lambda { |*args|  { :conditions => ["stickies.owner_id IN (?) or stickies.owner_id IS NULL", args.first] } }
  scope :with_frame, lambda { |*args| { :conditions => ["stickies.frame_id IN (?) or (stickies.frame_id IS NULL and 0 IN (?))", args.first, args.first] } }
  scope :search, lambda { |*args| {:conditions => [ 'LOWER(description) LIKE ?', '%' + args.first.downcase.split(' ').join('%') + '%' ] } }
  scope :updated_since, lambda {|*args| {:conditions => ["stickies.updated_at > ?", args.first] }}
  scope :with_date_for_calendar, lambda { |*args| { :conditions => ["DATE(stickies.created_at) >= ? and DATE(stickies.created_at) <= ?", args.first, args[1]]}}
  scope :with_due_date_for_calendar, lambda { |*args| { :conditions => ["DATE(stickies.due_date) >= ? and DATE(stickies.due_date) <= ?", args.first, args[1]]}}
  scope :with_start_date_for_calendar, lambda { |*args| { :conditions => ["DATE(stickies.start_date) >= ? and DATE(stickies.start_date) <= ?", args.first, args[1]]}}
  scope :with_end_date_for_calendar, lambda { |*args| { :conditions => ["DATE(stickies.end_date) >= ? and DATE(stickies.end_date) <= ?", args.first, args[1]]}}
  # scope :with_due_date_for_calendar, lambda { |*args| { :conditions => ["DATE(stickies.due_date) >= ? and DATE(stickies.due_date) <= ? or (stickies.due_date IS NULL and stickies.frame_id in (select frames.id from frames where DATE(frames.end_date) >= ? and DATE(frames.end_date) <= ?))", args.first, args[1], args.first, args[1]]}}

  scope :due_today,     lambda { |*args| { :conditions => ["stickies.status != 'completed' and DATE(stickies.due_date) = ?", Date.today]}}
  scope :past_due,      lambda { |*args| { :conditions => ["stickies.status != 'completed' and DATE(stickies.due_date) < ?", Date.today]}}
  scope :due_this_week, lambda { |*args| { :conditions => ["stickies.status != 'completed' and DATE(stickies.due_date) > ? and DATE(stickies.due_date) < ?", Date.today, Date.today + (7-Date.today.wday).days]}}


  before_create :set_start_date
  after_create :send_email
  
  before_save :set_end_date
  after_save :send_completion_email

  # Model Validation
  validates_presence_of :description, :project_id

  # Model Relationships
  belongs_to :user
  belongs_to :project, :touch => true
  belongs_to :group
  belongs_to :frame
  belongs_to :sticky

  belongs_to :owner, :class_name => 'User', :foreign_key => 'owner_id' 

  def name
    "ID ##{self.id}"
  end

  def destroy
    self.comments.destroy_all
    update_attribute :deleted, true
  end
  
  def comments(limit = nil)
    Comment.current.with_class_name(self.class.name).with_class_id(self.id).order('created_at desc').limit(limit)
  end
  
  def new_comment(current_user, description)
    Comment.create(:class_name => self.class.name, :class_id => self.id, :user_id => current_user.id, :description => description)
    self.touch
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

  private
  
  def send_email
    if self.project and not self.group and self.status != 'completed'
      all_users = (self.project.users + [self.project.user]).uniq - [self.user]
      all_users.each do |user_to_email|
        UserMailer.sticky_by_mail(self, user_to_email).deliver if user_to_email.active_for_authentication? and user_to_email.email_on?(:send_email) and user_to_email.email_on?(:sticky_creation) and user_to_email.email_on?("project_#{self.project.id}") and Rails.env.production?
      end
    end
  end

  # TODO: Currently assumes that the owner marks the sticky as completed.
  def send_completion_email
    if self.project and self.changes[:status] and self.changes[:status][1] == 'completed' and self.owner
      all_users = (self.project.users + [self.project.user]).uniq - [self.owner]
      all_users.each do |user_to_email|
        UserMailer.sticky_completion_by_mail(self, user_to_email).deliver if user_to_email.active_for_authentication? and user_to_email.email_on?(:send_email) and user_to_email.email_on?(:sticky_completion) and user_to_email.email_on?("project_#{self.project.id}") and Rails.env.production?
      end
    end
  end

  def set_start_date
    self.start_date = Date.today
  end

  def set_end_date
    self.end_date = ((self.changes[:status] and self.changes[:status][1] == 'completed') ? Date.today : nil) unless self.status == 'completed' and self.changes[:status] == nil
  end

end
