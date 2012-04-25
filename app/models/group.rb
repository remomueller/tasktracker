class Group < ActiveRecord::Base

  # Named Scopes
  scope :current, conditions: { deleted: false }
  scope :with_project, lambda { |*args| { conditions: ["groups.project_id IN (?) or (groups.project_id IS NULL and groups.user_id = ?)", args.first, args[1]] } }
  scope :search, lambda { |*args| {conditions: [ 'LOWER(id) LIKE ? or LOWER(description) LIKE ? or groups.template_id IN (select templates.id from templates where LOWER(templates.name) LIKE ?)', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%' ] } }

  # Hooks
  after_save :update_stickies_project

  # Model Validation
  validates_presence_of :project_id

  # Model Relationships
  belongs_to :user
  belongs_to :template #, conditions: { deleted: false }
  belongs_to :project #, conditions: { deleted: false }
  has_many :stickies, conditions: { deleted: false } #, order: 'stickies.due_date desc'

  def name
    "##{self.id}"
  end

  def destroy
    update_attribute :deleted, true
    self.stickies.destroy_all
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
      self.stickies.update_all project_id: self.project_id, frame_id: nil
    end
  end

end
