# frozen_string_literal: true

# Allows a user to filter tasks by tag
class TagFilter < ApplicationRecord
  # Model Validation
  validates :tag_id, :user_id, presence: true

  # Model Relationships
  belongs_to :tag
  belongs_to :user
end
