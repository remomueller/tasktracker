# frozen_string_literal: true

# Allows a user to filter tasks by project
class OwnerFilter < ApplicationRecord
  # Model Validation
  validates :owner_id, :user_id, presence: true

  # Model Relationships
  belongs_to :owner, class_name: 'User', foreign_key: 'owner_id'
  belongs_to :user
end
