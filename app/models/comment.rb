class Comment < ActiveRecord::Base
  # Named Scopes
  scope :current, :conditions => { :deleted => false }
  scope :with_object_model, lambda { |*args|  { :conditions => ["comments.object_model IN (?)", args.first] } }
  scope :with_object_id, lambda { |*args|  { :conditions => ["comments.object_id IN (?)", args.first] } }
  
  after_create :send_email
  
  # Model Validation
  validates_presence_of :description

  # Model Relationships
  belongs_to :user
  
  def destroy
    update_attribute :deleted, true
  end
  
  def comments(limit = nil)
    Comment.current.with_object_model(self.class.name).with_object_id(self.id).order('created_at desc').limit(limit)
  end
  
  def new_comment(current_user, description)
    Comment.create(:object_model => self.class.name, :object_id => self.id, :user_id => current_user.id, :description => description)
  end
  
  private
  
  def send_email
    @object = self.object_model.constantize.find_by_id(self.object_id)
    all_users = (@object.comments.collect{|c| c.user} + [@object.user]).uniq - [self.user]
    all_users.each do |user_to_email|
      UserMailer.comment_by_mail(self, @object, user_to_email).deliver if user_to_email.active?
    end
  end
  
end
