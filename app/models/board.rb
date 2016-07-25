# frozen_string_literal: true

# Categorizes a task on a project.
class Board < ApplicationRecord
  # Concerns
  include Searchable, Deletable, Filterable

  # Model Validation
  validates :name, :project_id, presence: true
  validates :name, uniqueness: { scope: [:deleted, :project_id] }

  # Model Relationships
  belongs_to :project
  belongs_to :user
  has_many :stickies, -> { current }

  def destroy
    stickies.update_all board_id: nil
    super
  end

  def short_time
    result = ''
    if start_date && start_date.year == Time.zone.today.year
      result += start_date.strftime('%m/%d')
    elsif start_date
      result += start_date.strftime('%m/%d/%Y')
    end
    if end_date && end_date.year == Time.zone.today.year
      result += " to #{end_date.strftime('%m/%d')}"
    elsif end_date
      result += " to #{end_date.strftime('%m/%d/%Y')}"
    end
    result
  end

  def self.natural_sort
    NaturalSort.sort where('').pluck(:name, :id)
  end
end
