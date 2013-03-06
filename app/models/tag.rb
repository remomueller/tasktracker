class Tag < ActiveRecord::Base

  # Concerns
  include Searchable, Deletable, Filterable

  # Named Scopes

  # Model Validation
  validates_presence_of :name, :project_id
  validates_uniqueness_of :name, scope: [:deleted, :project_id]

  # Model Relationships
  belongs_to :user
  belongs_to :project
  has_and_belongs_to_many :stickies

  # Model Relationships
  def self.natural_sort
    NaturalSort::naturalsort self.where('').collect{|t| [t.name, t.id]}
  end

end
