# frozen_string_literal: true

# Captures a users preferences for a project including favorite status and
# color.
class ProjectFavorite < ActiveRecord::Base
  # Model Validation
  validates :project_id, :user_id, presence: true

  # Model Relationships
  belongs_to :project
  belongs_to :user
end
