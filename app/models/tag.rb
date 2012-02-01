class Tag < ActiveRecord::Base
  # Named Scopes
  scope :current, conditions: { deleted: false }

  # Model Validation
  validates_presence_of :name

  # Model Relationships
  belongs_to :user
  belongs_to :project
  has_and_belongs_to_many :stickies

end
