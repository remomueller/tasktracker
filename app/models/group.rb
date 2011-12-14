class Group < ActiveRecord::Base

  # Named Scopes
  scope :current, conditions: { deleted: false }
  scope :with_project, lambda { |*args| { :conditions => ["groups.project_id IN (?) or (groups.project_id IS NULL and groups.user_id = ?)", args.first, args[1]] } }

  # Model Validation
  validates_presence_of :project_id

  # Model Relationships
  belongs_to :user
  belongs_to :template #, conditions: { deleted: false }
  has_many :stickies, conditions: { deleted: false }, order: 'stickies.due_date desc'

  def name
    "ID ##{self.id}"
  end

  def destroy
    update_attribute :deleted, true
    self.stickies.destroy_all
  end

end
