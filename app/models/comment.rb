class Comment < ActiveRecord::Base
  belongs_to :user
  
  scope :with_object_model, lambda { |*args|  { :conditions => ["likes.object_model IN (?)", args.first] } }
  scope :with_object_id, lambda { |*args|  { :conditions => ["likes.object_id IN (?)", args.first] } }
  
  def destroy
    update_attribute :deleted, true
  end
end
