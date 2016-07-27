# frozen_string_literal: true

# Allows a user to filter tasks by project
class ProjectFilter < ApplicationRecord
  # Model Validation
  validates :project_id, :user_id, presence: true

  # Model Relationships
  belongs_to :project
  belongs_to :user
end
