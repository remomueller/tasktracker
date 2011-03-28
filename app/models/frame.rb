class Frame < ActiveRecord::Base
  
  # Named Scopes
  scope :current, :conditions => { :deleted => false }
  scope :with_project, lambda { |*args| { :conditions => ["frames.project_id IN (?) or (frames.project_id IS NULL and frames.user_id = ?)", args.first, args[1]] } }
  
  # Model Validation
  validates_presence_of :name, :start_date, :end_date, :project_id
  
  # Model Relationships
  belongs_to :project
  belongs_to :user
  
end
