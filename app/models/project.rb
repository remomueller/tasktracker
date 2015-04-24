class Project < ActiveRecord::Base

  # Concerns
  include Searchable, Deletable

  # Named Scopes
  scope :with_user, lambda { |*args| where("projects.user_id = ? or projects.id in (select project_users.project_id from project_users where project_users.user_id = ? and project_users.allow_editing IN (?))", args.first, args.first, args[1]).references(:project_users) }
  scope :has_template, -> { where('projects.id in (select DISTINCT templates.project_id from templates where templates.deleted = ?)', false) }

  scope :by_favorite, lambda { |arg| joins("LEFT JOIN project_favorites ON project_favorites.project_id = projects.id and project_favorites.user_id = #{arg.to_i}") } #, order: "(project_favorites.favorite = 't') DESC"

  # Model Validation
  validates_presence_of :name, :user_id

  # Model Relationships
  belongs_to :user
  has_many :project_favorites
  has_many :project_users
  has_many :users, -> { where( deleted: false ).order( 'last_name, first_name' ) }, through: :project_users
  has_many :editors, -> { where('project_users.allow_editing = ? and users.deleted = ?', true, false) }, through: :project_users, source: :user
  has_many :viewers, -> { where('project_users.allow_editing = ? and users.deleted = ?', false, false) }, through: :project_users, source: :user
  has_many :stickies, -> { where deleted: false }
  has_many :boards, -> { where( deleted: false ).order( 'boards.end_date desc' ) }
  has_many :tags, -> { where( deleted: false ).order( 'tags.name' ) }
  has_many :templates, -> { where( deleted: false ).order( 'templates.name' ) }

  def color(current_user)
    current_user.colors["project_#{self.id}"].blank? ? colors(Project.order(:id).pluck(:id).index(self.id)) : current_user.colors["project_#{self.id}"]
  end

  def users_to_email(action)
    result = (self.users + [self.user]).uniq
    result = result.select{|u| u.email_on?(:send_email) and u.email_on?(action) and u.email_on?("project_#{self.id}") and u.email_on?("project_#{self.id}_#{action}") }
  end

  def project_link
    ENV['website_url'] + "/projects/#{self.id}"
  end

  def modifiable_by?(current_user)
    @modifiable_by ||= begin
      Project.current.with_user(current_user.id, true).where(id: self.id).count == 1
    end
  end

  def viewable_by?(current_user)
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

  def favorited_by?(current_user)
    project_favorite = self.project_favorites.find_by_user_id(current_user.id)
    not project_favorite.blank? and project_favorite.favorite?
  end

  private

  def colors(index)
    colors = ["#4733e6", "#7dd148", "#bfbf0d", "#9a9cff", "#16a766", "#4986e7", "#cb74e6", "#9f33e6", "#ff7637", "#92e1c0", "#d06c64", "#9fc6e7", "#c2c2c2", "#fa583c", "#AC725E", "#cca6ab", "#b89aff", "#f83b22", "#43d691", "#F691B2", "#a67ae2", "#FFAD46", "#b3dc6c"]
    colors[index.to_i % colors.size]
  end

end
