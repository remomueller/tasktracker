# frozen_string_literal: true

# The user class provides methods to scope resources in system that the user is
# allowed to view and edit.
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :encryptable, :confirmable, :lockable and :omniauthable
  devise :database_authenticatable, :registerable, :timeoutable,
         :recoverable, :rememberable, :trackable, :validatable

  EMAILABLES = [ [:sticky_creation, 'Receive email when a new task is created'],
                 [:sticky_completion, 'Receive email when a task is marked as completed'],
                 # [:sticky_due_time_changed, 'Receive email when a task\'s due date time is changed'],
                 [:sticky_comments, 'Receive email when a comment is added to a task'],
                 [:daily_stickies_due, 'Receive daily weekday emails if there are tasks due or past due'],
                 [:daily_digest, 'Receive daily digest emails of tasks that have been created and completed the previous day'] ]

  serialize :colors, Hash
  serialize :email_notifications, Hash

  # Concerns
  include Deletable

  # Named Scopes
  scope :search, -> (arg) { where('LOWER(first_name) LIKE ? or LOWER(last_name) LIKE ? or LOWER(email) LIKE ?', arg.to_s.downcase.gsub(/^| |$/, '%'), arg.to_s.downcase.gsub(/^| |$/, '%'), arg.to_s.downcase.gsub(/^| |$/, '%')) }
  scope :with_project, -> (*args) { where( "users.id in (select projects.user_id from projects where projects.id IN (?) and projects.deleted = ?) or users.id in (select project_users.user_id from project_users where project_users.project_id IN (?) and project_users.allow_editing IN (?))", args.first, false, args.first, args[1] ) }
  scope :with_name, -> (arg) { where("(users.first_name || ' ' || users.last_name) IN (?)", arg) }

  # Model Validation
  validates :first_name, :last_name, presence: true

  # Model Relationships
  has_many :projects, -> { current.order(:name) }
  has_many :project_favorites
  has_many :boards, -> { current }
  has_many :groups, -> { current }
  has_many :tags, -> { current }
  has_many :templates, -> { current.order(:created_at) }
  has_many :stickies, -> { current.order(:created_at) }
  has_many :comments, -> { current.order(created_at: :desc) }
  has_many :owned_stickies, -> { current.order(:created_at) }, class_name: 'Sticky', foreign_key: 'owner_id'

  # User Methods

  def avatar_url(size = 80, default = 'mm')
    gravatar_id = Digest::MD5.hexdigest(self.email.to_s.downcase)
    "//gravatar.com/avatar/#{gravatar_id}.png?&s=#{size}&r=pg&d=#{default}"
  end

  def associated_users
    User.current.with_project(self.all_viewable_projects.pluck(:id), [true, false])
  end

  def associated_users_assigned_tasks
    User.current.where(id: Sticky.where(owner_id: associated_users.pluck(:id), project_id: all_viewable_projects.pluck(:id)).pluck(:owner_id))
  end

  # Overriding Devise built-in active_for_authentication? method
  def active_for_authentication?
    super && !deleted?
  end

  def destroy
    super
    update_column :updated_at, Time.zone.now
  end

  def email_on?(value)
    active_for_authentication? && [nil, true].include?(email_notifications[value.to_s])
  end

  def all_projects
    @all_projects ||= begin
      Project.current.with_user(self.id, true) #.order('name')
    end
  end

  def all_viewable_projects
    @all_viewable_projects ||= begin
      Project.current.with_user(self.id, [true, false]) #.order('name')
    end
  end

  def all_favorite_projects
    @all_favorite_projects ||= begin
      self.all_projects.by_favorite(self.id).where("project_favorites.favorite = ?", true).order('name')
    end
  end

  def all_other_projects
    @all_other_projects ||= begin
      self.all_projects.where("projects.id NOT IN (?)", [0] + self.all_favorite_projects.pluck("projects.id")).order('name')
    end
  end

  def all_stickies
    @all_stickies ||= begin
      Sticky.current.where(project_id: self.all_projects.pluck(:id)).order('created_at DESC')
    end
  end

  def all_stickies_due_today
    self.all_stickies.due_today.with_owner(self.id)
  end

  def all_stickies_past_due
    self.all_stickies.past_due.with_owner(self.id)
  end

  def all_stickies_due_upcoming
    self.all_stickies.due_upcoming.with_owner(self.id)
  end

  def all_deliverable_projects
    @all_deliverable_projects ||= begin
      self.all_projects.select{|p| self.email_on?(:send_email) and self.email_on?(:daily_stickies_due) and self.email_on?("project_#{p.id}") and self.email_on?("project_#{p.id}_daily_stickies_due") }
    end
  end

  def all_deliverable_stickies_due_today
    self.all_stickies_due_today.where(project_id: self.all_deliverable_projects.collect{|p| p.id})
  end

  def all_deliverable_stickies_past_due
    self.all_stickies_past_due.where(project_id: self.all_deliverable_projects.collect{|p| p.id})
  end

  def all_deliverable_stickies_due_upcoming
    self.all_stickies_due_upcoming.where(project_id: self.all_deliverable_projects.collect{|p| p.id})
  end

  def all_digest_projects
    @all_digest_projects ||= begin
      self.all_projects.select{|p| self.email_on?(:send_email) and self.email_on?(:daily_digest) and self.email_on?("project_#{p.id}") and self.email_on?("project_#{p.id}_daily_digest") }
    end
  end

  # All tasks created in the last day, or over the weekend if it's Monday
  # Ex: On Monday, returns tasks created since Friday morning (Time.zone.now - 3.day)
  # Ex: On Tuesday, returns tasks created since Monday morning (Time.zone.now - 1.day)
  def digest_stickies_created
    @digest_stickies_created ||= begin
      self.all_stickies.where(project_id: self.all_digest_projects.collect{|p| p.id}, completed: false).where("created_at > ?", (Time.zone.now.monday? ? Time.zone.now - 3.day : Time.zone.now - 1.day))
    end
  end

  def digest_stickies_completed
    @digest_stickies_completed ||= begin
      self.all_stickies.where(project_id: self.all_digest_projects.collect{|p| p.id}).where("end_date >= ?", (Date.today.monday? ? Date.today - 3.day : Date.today - 1.day))
    end
  end

  def digest_comments
    @digest_comments ||= begin
      self.all_viewable_comments.with_project(self.all_digest_projects.collect{|p| p.id}).where("created_at > ?", (Time.zone.now.monday? ? Time.zone.now - 3.day : Time.zone.now - 1.day)).order('created_at ASC')
    end
  end

  def all_viewable_stickies
    @all_viewable_stickies ||= begin
      Sticky.current.where(project_id: self.all_viewable_projects.pluck(:id))
    end
  end

  def all_groups
    @all_groups ||= begin
      Group.current.where(project_id: self.all_projects.pluck(:id))
    end
  end

  def all_viewable_groups
    @all_viewable_groups ||= begin
      Group.current.where(project_id: self.all_viewable_projects.pluck(:id))
    end
  end

  def all_boards
    @all_boards ||= begin
      Board.current.where(project_id: self.all_projects.pluck(:id))
    end
  end

  def all_viewable_boards
    @all_viewable_boards ||= begin
      Board.current.where(project_id: self.all_viewable_projects.pluck(:id))
    end
  end

  def all_tags
    @all_tags ||= begin
      Tag.current.where(project_id: self.all_projects.pluck(:id))
    end
  end

  def all_viewable_tags
    @all_viewable_tags ||= begin
      Tag.current.where(project_id: self.all_viewable_projects.pluck(:id))
    end
  end

  def all_templates
    @all_templates ||= begin
      Template.current.where(project_id: self.all_projects.pluck(:id))
    end
  end

  def all_viewable_templates
    @all_viewable_templates ||= begin
      Template.current.where(project_id: self.all_viewable_projects.pluck(:id))
    end
  end

  def all_comments
    @all_comments ||= begin
      self.comments
    end
  end

  def all_viewable_comments
    @all_viewable_comments ||= begin
      Comment.current.where(sticky_id: self.all_viewable_stickies.pluck(:id))
    end
  end

  def all_deletable_comments
    @all_deletable_comments ||= begin
      Comment.current.where("sticky_id IN (?) or user_id = ?", all_stickies.pluck(:id), id)
    end
  end

  def name
    "#{first_name} #{last_name}"
  end

  def reverse_name
    "#{last_name}, #{first_name}"
  end

  def nickname
    "#{first_name} #{last_name.first}"
  end
end
