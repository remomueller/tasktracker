class Frame < ActiveRecord::Base
  
  # Named Scopes
  scope :current, :conditions => { :deleted => false }
  scope :with_project, lambda { |*args| { :conditions => ["frames.project_id IN (?) or (frames.project_id IS NULL and frames.user_id = ?)", args.first, args[1]] } }
  scope :search, lambda { |*args| {:conditions => [ 'LOWER(name) LIKE ? or LOWER(description) LIKE ?', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%' ] } }
  scope :active_today, lambda { |*args| { :conditions => ["frames.start_date <= DATE(?) and frames.end_date >= DATE(?)", Date.today, Date.today] } }
  scope :active_date, lambda { |*args| { :conditions => ["frames.start_date <= DATE(?) and frames.end_date >= DATE(?)", args.first, args.first] } }
  
  # Model Validation
  validates_presence_of :name, :project_id, :start_date, :end_date
  
  # Model Relationships
  belongs_to :project
  belongs_to :user
  has_many :stickies, :conditions => { :deleted => false }

  def destroy
    update_attribute :deleted, true
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
  
  def long_time
    result = ''
    if self.start_date and self.start_date.year == Date.today.year
      result << self.start_date.strftime('%b %d (%a)')
    elsif self.start_date
      result << self.start_date.strftime('%b %d, %Y (%a)')
    end
    if self.end_date and self.end_date.year == Date.today.year
      result << " to #{self.end_date.strftime('%b %d (%a)')}"
    elsif self.end_date
      result << " to #{self.end_date.strftime('%b %d, %Y (%a)')}"
    end
    result
  end
  
end
