# frozen_string_literal: true

# Allows users to collaborate together to manage and complete tasks.
class Project < ApplicationRecord
  # Concerns
  include Searchable, Deletable

  # Named Scopes
  scope :with_user, -> (*args) { where("projects.user_id = ? or projects.id in (select project_users.project_id from project_users where project_users.user_id = ? and project_users.allow_editing IN (?))", args.first, args.first, args[1]).references(:project_users) }
  scope :has_template, -> { where('projects.id in (select DISTINCT templates.project_id from templates where templates.deleted = ?)', false) }
  scope :by_favorite, -> (arg) { joins("LEFT JOIN project_preferences ON project_preferences.project_id = projects.id and project_preferences.user_id = #{arg.to_i}") } #, order: "(project_preferences.favorite = 't') DESC"

  # Model Validation
  validates :name, :user_id, presence: true

  # Model Relationships
  belongs_to :user
  has_many :project_preferences
  has_many :project_users
  has_many :users, -> { current.order(:last_name, :first_name) }, through: :project_users
  has_many :editors, -> { where('project_users.allow_editing = ? and users.deleted = ?', true, false) }, through: :project_users, source: :user
  has_many :viewers, -> { where('project_users.allow_editing = ? and users.deleted = ?', false, false) }, through: :project_users, source: :user
  has_many :stickies, -> { current }
  has_many :boards, -> { current.order(end_date: :desc) }
  has_many :groups, -> { current }
  has_many :tags, -> { current.order(:name) }
  has_many :templates, -> { current.order(:name) }

  def self.searchable_attributes
    %w(name)
  end

  def color(current_user)
    project_preference = project_preferences.find_by_user_id(current_user.id)
    if project_preference && project_preference.color.present?
      project_preference.color
    else
      colors(Project.order(:id).pluck(:id).index(id))
    end
  end

  def text_color(current_user)
    '#fff'
  end

  def users_to_email
    (users + [user]).uniq.select do |u|
      !u.deleted? && u.emails_enabled? && emails_enabled?(u)
    end
  end

  def modifiable_by?(current_user)
    Project.current.with_user(current_user.id, true).where(id: id).count == 1
  end

  def viewable_by?(current_user)
    Project.current.with_user(current_user.id, [true, false]).where(id: id).count == 1
  end

  def sticky_count(board = 'all', filter = 'completed', user = nil)
    scope = stickies.where(completed: (filter == 'completed'))
    scope = scope.due_date_before_or_blank(Time.zone.today) if filter == 'past_due'
    scope = scope.due_date_after_or_blank(Time.zone.today) if filter == 'upcoming'
    scope = scope.where(board_id: board) if board != 'all' # Holding Pen
    scope = scope.with_owner(user.id) if user
    scope.count
  end

  def archived_by?(current_user)
    project_preference = project_preferences.find_by_user_id(current_user.id)
    project_preference.present? && project_preference.archived?
  end

  def favorited_by?(current_user)
    project_preference = project_preferences.find_by_user_id(current_user.id)
    project_preference.present? && project_preference.favorite?
  end

  def emails_enabled?(current_user)
    project_preference = project_preferences.find_by_user_id(current_user.id)
    project_preference.nil? || (project_preference.present? && project_preference.emails_enabled?)
  end

  private

  def colors(index)
    colors = %w(
      #4733e6 #7dd148 #bfbf0d #9a9cff #16a766 #4986e7 #cb74e6 #9f33e6 #ff7637
      #92e1c0 #d06c64 #9fc6e7 #c2c2c2 #fa583c #AC725E #cca6ab #b89aff #f83b22
      #43d691 #F691B2 #a67ae2 #FFAD46 #b3dc6c
    )
    colors[index.to_i % colors.size]
  end
end
