class ProjectFavorite < ActiveRecord::Base
  # attr_accessible :user_id, :favorite

  # Model Validation
  validates_presence_of :project_id, :user_id

  # Model Relationships
  belongs_to :project
  belongs_to :user
end
