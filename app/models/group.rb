class Group < ActiveRecord::Base

  # Named Scopes
  scope :current, conditions: { deleted: false }

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
