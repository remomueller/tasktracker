class Project < ActiveRecord::Base
  # attr_accessible :name, :description, :status, :start_date, :end_date

  STATUS = ["planned", "ongoing", "completed"].collect{|i| [i,i]}
  serialize :old_tags, Array # Deprecated however used to migrate from old schema to new tag framework

  # Concerns
  include Searchable, Deletable

  # Named Scopes
  scope :with_user, lambda { |*args| { conditions: ["projects.user_id = ? or projects.id in (select project_users.project_id from project_users where project_users.user_id = ? and project_users.allow_editing IN (?))", args.first, args.first, args[1]] } }
  scope :has_template, lambda { |*args| { conditions: ['projects.id in (select DISTINCT templates.project_id from templates where templates.deleted = ?)', false] } }

  scope :by_favorite, lambda { |*args| { joins: "LEFT JOIN project_favorites ON project_favorites.project_id = projects.id and project_favorites.user_id = #{args.first.to_i}" } } #, order: "(project_favorites.favorite = 't') DESC"

  # Model Validation
  validates_presence_of :name, :user_id

  # Model Relationships
  belongs_to :user
  has_many :project_favorites
  has_many :project_users
  has_many :users, through: :project_users, conditions: { deleted: false }, order: 'last_name, first_name'
  has_many :editors, through: :project_users, source: :user, conditions: ['project_users.allow_editing = ? and users.deleted = ?', true, false]
  has_many :viewers, through: :project_users, source: :user, conditions: ['project_users.allow_editing = ? and users.deleted = ?', false, false]
  has_many :stickies, conditions: { deleted: false } #, order: 'stickies.created_at desc'
  has_many :boards, conditions: { deleted: false }, order: 'boards.end_date desc'
  has_many :tags, conditions: { deleted: false }, order: 'tags.name'
  has_many :templates, conditions: { deleted: false }, order: 'templates.name'

  def color(current_user)
    current_user.colors["project_#{self.id}"].blank? ? colors(Project.order(:id).pluck(:id).index(self.id)) : current_user.colors["project_#{self.id}"]
  end

  def users_to_email(action)
    result = (self.users + [self.user]).uniq
    result = result.select{|u| u.email_on?(:send_email) and u.email_on?(action) and u.email_on?("project_#{self.id}") and u.email_on?("project_#{self.id}_#{action}") }
  end

  def as_json(options={})
    json = super(only: [:id, :user_id, :name, :description, :start_date, :end_date, :created_at, :updated_at], methods: [:project_link, :tags])
    json[:color] = options[:current_user].blank? ? '#777777' : self.color(options[:current_user])
    project_favorite = (options[:current_user].blank? ? nil : self.project_favorites.find_by_user_id(options[:current_user].id))
    json[:favorited] = (not project_favorite.blank? and project_favorite.favorite?)
    json
  end

  def project_link
    SITE_URL + "/projects/#{self.id}"
  end

  def modifiable_by?(current_user)
    # current_user.all_projects.pluck(:id).include?(self.id)
    @modifiable_by ||= begin
      Project.current.with_user(current_user.id, true).where(id: self.id).count == 1
    end
  end

  def viewable_by?(current_user)
    # current_user.all_viewable_projects.pluck(:id).include?(self.id)
    @viewable_by ||= begin
      Project.current.with_user(current_user.id, [true, false]).where(id: self.id).count == 1
    end
  end

  def sticky_count(board = "all", filter = 'completed', user = nil)
    scope = stickies.where(completed: (filter == 'completed'))
    scope = scope.due_date_before_or_blank(Date.today) if filter == 'past_due'
    scope = scope.due_date_after_or_blank(Date.today) if filter == 'upcoming'
    scope = scope.where(board_id: board) if board != 'all' # Holding Pen
    scope = scope.with_owner(user.id) if user
    scope.count
  end

  private

  def colors(index)
    colors = ["#4733e6", "#7dd148", "#bfbf0d", "#9a9cff", "#16a766", "#4986e7", "#cb74e6", "#9f33e6", "#ff7637", "#92e1c0", "#d06c64", "#9fc6e7", "#c2c2c2", "#fa583c", "#AC725E", "#cca6ab", "#b89aff", "#f83b22", "#43d691", "#F691B2", "#a67ae2", "#FFAD46", "#b3dc6c"]
    colors[index.to_i % colors.size]
  end

end
