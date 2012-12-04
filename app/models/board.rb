class Board < ActiveRecord::Base
  attr_accessible :name, :description, :start_date, :end_date, :archived, :project_id, :user_id

  # Named Scopes
  scope :current, conditions: { deleted: false }
  scope :with_project, lambda { |*args| { conditions: ["boards.project_id IN (?) or (boards.project_id IS NULL and boards.user_id = ?)", args.first, args[1]] } }
  scope :search, lambda { |*args| {conditions: [ 'LOWER(name) LIKE ? or LOWER(description) LIKE ?', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%' ] } }
  scope :active_today, lambda { |*args| { conditions: ["boards.start_date <= DATE(?) and boards.end_date >= DATE(?)", Date.today, Date.today] } }
  scope :active_date, lambda { |*args| { conditions: ["boards.start_date <= DATE(?) and boards.end_date >= DATE(?)", args.first, args.first] } }

  # Model Validation
  validates_presence_of :name, :project_id #, :start_date, :end_date
  validates_uniqueness_of :name, scope: [:deleted, :project_id]

  # Model Relationships
  belongs_to :project
  belongs_to :user
  has_many :stickies, conditions: { deleted: false }

  def destroy
    update_column :deleted, true
    self.stickies.update_all(board_id: nil)
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
    NaturalSort::naturalsort self.where('').collect{|f| [f.name, f.id]}
  end

  def name_with_incomplete_count
    self.name + (self.stickies.where(completed: false).size > 0 ? " (#{self.stickies.where(completed: false).size})" : "")
  end

  def incomplete_count(user = nil)
    if user
      self.stickies.where(completed: false).where(owner_id: user.id).size
    else
      self.stickies.where(completed: false).size
    end
  end
end
