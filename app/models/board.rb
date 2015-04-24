class Board < ActiveRecord::Base

  # Concerns
  include Searchable, Deletable, Filterable

  # Model Validation
  validates_presence_of :name, :project_id
  validates_uniqueness_of :name, scope: [:deleted, :project_id]

  # Model Relationships
  belongs_to :project
  belongs_to :user
  has_many :stickies, -> { where deleted: false }

  def destroy
    self.stickies.update_all(board_id: nil)
    super
  end

  def short_time
    result = ''
    if self.start_date and self.start_date.year == Date.today.year
      result << self.start_date.strftime('%m/%d')
    elsif self.start_date
      result << self.start_date.strftime('%m/%d/%Y')
    end
    if self.end_date and self.end_date.year == Date.today.year
      result << " to #{self.end_date.strftime('%m/%d')}"
    elsif self.end_date
      result << " to #{self.end_date.strftime('%m/%d/%Y')}"
    end
    result
  end

  def self.natural_sort
    NaturalSort.sort self.where('').collect{|f| [f.name, f.id]}
  end

end
