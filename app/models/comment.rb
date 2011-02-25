class Comment < ActiveRecord::Base
  belongs_to :user
  
  # Named Scopes
  scope :current, :conditions => { :deleted => false }
  scope :with_object_model, lambda { |*args|  { :conditions => ["comments.object_model IN (?)", args.first] } }
  scope :with_object_id, lambda { |*args|  { :conditions => ["comments.object_id IN (?)", args.first] } }
  
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
