# frozen_string_literal: true

# Tracks if a user has seen changes to task comments.
class Notification < ApplicationRecord
  # Model Validation
  validates :user_id, :project_id, presence: true

  # Model Relationships
  belongs_to :user
  belongs_to :project
  belongs_to :comment
  belongs_to :sticky
  belongs_to :group

  # Notification Methods

  def mark_as_unread!
    update created_at: Time.zone.now, read: false
  end
end
