class Project < ActiveRecord::Base

  STATUS = ["planned", "ongoing", "completed"].collect{|i| [i,i]}
  serialize :old_tags, Array # Deprecated however used to migrate from old schema to new tag framework

  # Named Scopes
  scope :current, conditions: { deleted: false }
  scope :with_user, lambda { |*args| { conditions: ["projects.user_id = ? or projects.id in (select project_users.project_id from project_users where project_users.user_id = ? and project_users.allow_editing IN (?))", args.first, args.first, args[1]] } }
  scope :search, lambda { |*args| { conditions: [ 'LOWER(name) LIKE ? or LOWER(description) LIKE ?', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%' ] } }

  # scope :by_favorite, lambda { |*args| {include: :project_favorites, conditions: ["project_favorites.user_id = ? or project_favorites.user_id IS NULL", args.first], order: "(project_favorites.favorite = 0) ASC" } }
  scope :by_favorite, lambda { |*args| { joins: "LEFT JOIN project_favorites ON project_favorites.project_id = projects.id and project_favorites.user_id = #{args.first}" } } #, order: "(project_favorites.favorite = 1) DESC"

  # Model Validation
  validates_presence_of :name


  # Model Relationships
  belongs_to :user
  has_many :project_favorites
  has_many :project_users
  has_many :users, through: :project_users, conditions: { deleted: false }, order: 'last_name, first_name'
  has_many :editors, through: :project_users, source: :user, conditions: ['project_users.allow_editing = ? and users.deleted = ?', true, false]
  has_many :viewers, through: :project_users, source: :user, conditions: ['project_users.allow_editing = ? and users.deleted = ?', false, false]
  has_many :stickies, conditions: { deleted: false } #, order: 'stickies.created_at desc'
  has_many :frames, conditions: { deleted: false }, order: 'frames.end_date desc'
  has_many :tags, conditions: { deleted: false }, order: 'tags.name'
  has_many :templates, conditions: { deleted: false }, order: 'templates.name'

  def color(current_user)
    current_user.colors["project_#{self.id}"].blank? ? colors(Project.pluck(:id).index(self.id)) : current_user.colors["project_#{self.id}"]
  end

  def destroy
    # self.stickies.destroy_all
    # self.frames.destroy_all
    # self.templates.destroy_all
    # self.tags.destroy_all
    update_attribute :deleted, true
  end

  def users_to_email(action)
    result = (self.users + [self.user]).uniq
    result = result.select{|u| u.email_on?(:send_email) and u.email_on?(action) and u.email_on?("project_#{self.id}") and u.email_on?("project_#{self.id}_#{action}") }
  end

  private

  def colors(index)
    colors = ["#4733e6", "#7dd148", "#bfbf0d", "#9a9cff", "#16a766", "#4986e7", "#cb74e6", "#9f33e6", "#ff7637", "#92e1c0", "#d06c64", "#9fc6e7", "#c2c2c2", "#fa583c", "#AC725E", "#cca6ab", "#b89aff", "#f83b22", "#43d691", "#F691B2", "#a67ae2", "#FFAD46", "#b3dc6c"]
    colors[index.to_i % colors.size]
  end

end
