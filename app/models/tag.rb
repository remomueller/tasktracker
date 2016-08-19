# frozen_string_literal: true

# Allows tasks to be tagged
class Tag < ApplicationRecord
  # Concerns
  include Searchable, Deletable, Filterable

  # Scopes

  # Model Validation
  validates :name, :project_id, presence: true
  validates :name, uniqueness: { scope: [:deleted, :project_id] }

  # Model Relationships
  belongs_to :user
  belongs_to :project
  # Replace HABTM relationship
  has_and_belongs_to_many :stickies

  # Model Relationships
  def self.natural_sort
    NaturalSort.sort where('').pluck(:name, :id)
  end
end
