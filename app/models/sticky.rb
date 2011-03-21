class Sticky < ActiveRecord::Base

  STATUS = ["planned", "ongoing", "completed"].collect{|i| [i,i]}
  STICKY_TYPE = ["generic", "action item", "goal", "roadblock"].collect{|i| [i,i]}

  # Named Scopes
  scope :current, :conditions => { :deleted => false }
  scope :status, lambda { |*args|  { :conditions => ["stickies.status IN (?)", args.first] } }
  scope :with_project, lambda { |*args| { :conditions => ["stickies.project_id IN (?)", args.first] } }

  after_create :send_email

  # Model Validation
  validates_presence_of :description

  # Model Relationships
  belongs_to :user
  belongs_to :project, :touch => true
  belongs_to :sticky

  belongs_to :owner, :class_name => 'User', :foreign_key => 'owner_id' 

  def name
    "ID ##{self.id}"
  end

  def destroy
    update_attribute :deleted, true
  end
  
  def comments(limit = nil)
    Comment.current.with_object_model(self.class.name).with_object_id(self.id).order('created_at desc').limit(limit)
  end
  
  def new_comment(current_user, description)
    Comment.create(:object_model => self.class.name, :object_id => self.id, :user_id => current_user.id, :description => description)
    self.touch
  end

  private
  
  def send_email
    if self.project
      all_users = (self.project.users + [self.project.user]).uniq - [self.user]
      all_users.each do |user_to_email|
        UserMailer.sticky_by_mail(self, user_to_email).deliver if user_to_email.active?
      end
    end
  end

end
