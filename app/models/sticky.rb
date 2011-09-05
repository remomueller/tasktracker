class Sticky < ActiveRecord::Base

  STATUS = ["planned", "ongoing", "completed"].collect{|i| [i,i]}
  STICKY_TYPE = ["generic", "action item", "goal", "roadblock"].collect{|i| [i,i]}

  # Named Scopes
  scope :current, :conditions => { :deleted => false }
  scope :status, lambda { |*args|  { :conditions => ["stickies.status IN (?)", args.first] } }
  scope :with_project, lambda { |*args| { :conditions => ["stickies.project_id IN (?) or (stickies.project_id IS NULL and stickies.user_id = ?)", args.first, args[1]] } }
  scope :with_creator, lambda { |*args|  { :conditions => ["stickies.user_id IN (?)", args.first] } }
  scope :with_frame, lambda { |*args| { :conditions => ["stickies.frame_id IN (?) or (stickies.frame_id IS NULL and 0 IN (?))", args.first, args.first] } }
  scope :search, lambda { |*args| {:conditions => [ 'LOWER(description) LIKE ?', '%' + args.first.downcase.split(' ').join('%') + '%' ] } }
  scope :updated_since, lambda {|*args| {:conditions => ["stickies.updated_at > ?", args.first] }}
  scope :with_date_for_calendar, lambda { |*args| { :conditions => ["DATE(stickies.created_at) >= ? and DATE(stickies.created_at) <= ?", args.first, args[1]]}}

  after_create :send_email

  # Model Validation
  validates_presence_of :description

  # Model Relationships
  belongs_to :user
  belongs_to :project, :touch => true
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

  private
  
  def send_email
    if self.project
      all_users = (self.project.users + [self.project.user]).uniq - [self.user]
      all_users.each do |user_to_email|
        UserMailer.sticky_by_mail(self, user_to_email).deliver if user_to_email.active_for_authentication? and user_to_email.email_on?(:send_email) and user_to_email.email_on?(:sticky_creation) and user_to_email.email_on?("project_#{self.project.id}") and Rails.env.production?
      end
    end
  end

end
