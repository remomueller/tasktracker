class Group < ActiveRecord::Base
  attr_accessible :description, :project_id, :template_id, :board_id, :initial_due_date

  attr_accessor :board_id, :initial_due_date

  # Concerns
  include Deletable

  # Named Scopes
  scope :search, lambda { |arg| { conditions: [ 'LOWER(id) LIKE ? or LOWER(description) LIKE ? or groups.template_id IN (select templates.id from templates where LOWER(templates.name) LIKE ?)', arg.downcase.gsub(/^| |$/, '%'), arg.downcase.gsub(/^| |$/, '%'), arg.downcase.gsub(/^| |$/, '%') ] } }

  # Hooks
  after_save :update_stickies_project

  # Model Validation
  validates_presence_of :project_id

  # Model Relationships
  belongs_to :user
  belongs_to :template
  belongs_to :project
  has_many :stickies, conditions: { deleted: false }

  def name
    "##{self.id}"
  end

  def short_description(fallback = "Group #{self.name}")
    result = self.description.to_s.split(/[\r\n]/).collect{|i| i.strip}.select{|i| not i.blank?}.first
    result = fallback unless result
    result
  end

  def short_description_second_half
    self.description.to_s.strip.gsub(self.short_description, "").strip
  end

  def destroy
    self.stickies.destroy_all
    super
  end

  def export_ics
    RiCal.Calendar do |cal|
      self.stickies.each do |sticky|
        sticky.export_ics_block_evt(cal)
      end
    end.to_s
  end

  def creator_name
    self.user.name
  end

  def group_link
    SITE_URL + "/groups/#{self.id}"
  end

  private

  def update_stickies_project
    if self.changes[:project_id]
      self.stickies.update_all project_id: self.project_id, board_id: nil
    end
  end

end
