class Sticky < ActiveRecord::Base

  STATUS = ["planned", "ongoing", "completed"].collect{|i| [i,i]}
  STICKY_TYPE = ["generic", "action item", "goal", "roadblock"].collect{|i| [i,i]}

  # Named Scopes
  scope :current, :conditions => { :deleted => false }
  scope :status, lambda { |*args|  { :conditions => ["stickies.status IN (?)", args.first] } }
  scope :with_project, lambda { |*args| { :conditions => ["stickies.project_id IN (?)", args.first] } }

  # Model Validation
  validates_presence_of :description

  # Model Relationships
  belongs_to :user
  belongs_to :project
  belongs_to :sticky

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
  end

end
