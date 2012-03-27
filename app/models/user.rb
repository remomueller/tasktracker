class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, and :lockable
  devise :database_authenticatable, :registerable, :timeoutable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :first_name, :last_name

  after_create :notify_system_admins
  before_update :status_activated

  STATUS = ["active", "denied", "inactive", "pending"].collect{|i| [i,i]}

  VALID_API_TOKENS = ['screen_token']

  EMAILABLES = [ [:sticky_creation, 'Receive email when a new sticky is created'],
                 [:sticky_completion, 'Receive email when a sticky is marked as completed'],
                 [:sticky_due_time_changed, 'Receive email when a sticky\'s due date time is changed'],
                 [:project_comments, 'Receive email when a comment is added to a project'],
                 [:sticky_comments, 'Receive email when a comment is added to a sticky'],
                 [:daily_stickies_due, 'Receive daily weekday emails if there are stickies due or past due'] ]

  serialize :email_notifications, Hash
  serialize :hidden_project_ids, Array
  serialize :colors, Hash
  serialize :settings, Hash

  # Named Scopes
  scope :current, conditions: { deleted: false }
  scope :human, conditions: { service_account: false }
  scope :service_account, conditions: { service_account: true }
  scope :status, lambda { |*args|  { conditions: ["users.status IN (?)", args.first] } }
  scope :search, lambda { |*args| {conditions: [ 'LOWER(first_name) LIKE ? or LOWER(last_name) LIKE ? or LOWER(email) LIKE ?', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%' ] } }
  scope :system_admins, conditions: { system_admin: true }
  scope :with_project, lambda { |*args| { conditions: ["users.id in (select projects.user_id from projects where projects.id IN (?) and projects.deleted = ?) or users.id in (select project_users.user_id from project_users where project_users.project_id IN (?) and project_users.allow_editing IN (?))", args.first, false, args.first, args[1]] } }

  # Model Validation
  validates_presence_of     :first_name
  validates_presence_of     :last_name

  # Model Relationships
  has_many :authentications
  has_many :projects, conditions: { deleted: false }, order: 'name'
  has_many :project_favorites
  has_many :frames, conditions: { deleted: false }
  has_many :groups, conditions: { deleted: false }
  has_many :tags, conditions: { deleted: false }
  has_many :templates, conditions: { deleted: false }, order: 'created_at'
  has_many :stickies, conditions: { deleted: false }, order: 'created_at'
  has_many :comments, conditions: { deleted: false }, order: 'created_at DESC'

  has_many :owned_stickies, class_name: 'Sticky', foreign_key: 'owner_id', conditions: { deleted: false }, order: 'created_at'

  # User Methods

  def self.find_by_api_token(api_service, api_token)
    User.send("find_by_"+api_service, api_token)
  end


  def generate_api_token!(api_token)
    message = ''
    if User::VALID_API_TOKENS.include?(api_token)
      begin
        self.update_attribute api_token.to_sym, (Digest::SHA1.hexdigest(Time.now.usec.to_s) + Digest::SHA1.hexdigest(Time.now.usec.to_s) + Digest::SHA1.hexdigest(Time.now.usec.to_s) + Digest::SHA1.hexdigest(Time.now.usec.to_s))[0..127]
      rescue ActiveRecord::RecordNotUnique
        message = 'Error - Please try regenerating'
      end
    end
    self.reload
    message
  end

  # Overriding Devise built-in active_for_authentication? method
  def active_for_authentication?
    super and self.status == 'active' and not self.deleted?
  end

  def destroy
    update_attribute :deleted, true
    update_attribute :status, 'inactive'
  end

  def email_on?(value)
    self.active_for_authentication? and [nil, true].include?(self.email_notifications[value.to_s])
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

  def all_stickies
    @all_stickies ||= begin
      Sticky.current.with_project(self.all_projects.collect{|p| p.id}, self.id).order('created_at DESC')
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
    self.all_stickies_due_today.with_project(self.all_deliverable_projects.collect{|p| p.id}, self.id)
  end

  def all_deliverable_stickies_past_due
    self.all_stickies_past_due.with_project(self.all_deliverable_projects.collect{|p| p.id}, self.id)
  end

  def all_deliverable_stickies_due_upcoming
    self.all_stickies_due_upcoming.with_project(self.all_deliverable_projects.collect{|p| p.id}, self.id)
  end

  def all_viewable_stickies
    @all_viewable_stickies ||= begin
      Sticky.current.with_project(self.all_viewable_projects.collect{|p| p.id}, self.id) # .order('created_at DESC')
    end
  end

  def all_groups
    @all_groups ||= begin
      Group.current.with_project(self.all_projects.collect{|p| p.id}, self.id) #.order('created_at DESC')
    end
  end

  def all_viewable_groups
    @all_viewable_groups ||= begin
      Group.current.with_project(self.all_viewable_projects.collect{|p| p.id}, self.id) #.order('created_at DESC')
    end
  end

  def all_frames
    @all_frames ||= begin
      Frame.current.with_project(self.all_projects.collect{|p| p.id}, self.id) #.order('created_at DESC')
    end
  end

  def all_viewable_frames
    @all_viewable_frames ||= begin
      Frame.current.with_project(self.all_viewable_projects.collect{|p| p.id}, self.id) #.order('created_at DESC')
    end
  end

  def all_tags
    @all_tags ||= begin
      Tag.current.with_project(self.all_projects.collect{|p| p.id}, self.id) #.order('created_at DESC')
    end
  end

  def all_viewable_tags
    @all_viewable_tags ||= begin
      Tag.current.with_project(self.all_viewable_projects.collect{|p| p.id}, self.id) #.order('created_at DESC')
    end
  end

  def all_templates
    @all_templates ||= begin
      if self.service_account?
        Template.current
      else
        Template.current.with_project(self.all_projects.collect{|p| p.id}, self.id) #.order('created_at DESC')
      end
    end
  end

  def all_viewable_templates
    @all_viewable_templates ||= begin
      Template.current.with_project(self.all_viewable_projects.collect{|p| p.id}, self.id) #.order('created_at DESC')
    end
  end

  def all_comments
    @all_comments ||= begin
      self.comments
    end
  end

  def all_viewable_comments
    @all_viewable_comments ||= begin
      Comment.current.with_two_class_names_and_ids('Project', self.all_viewable_projects.collect{|p| p.id}, 'Sticky', self.all_viewable_stickies.collect{|s| s.id}).order('created_at DESC')
    end
  end

  def all_deletable_comments
    @all_comments ||= begin
      Comment.current.with_two_class_names_and_ids('Project', self.all_projects.collect{|p| p.id}, 'Sticky', self.all_stickies.collect{|s| s.id}).order('created_at DESC')
    end
  end

  def all_movable_comments
    self.all_deletable_comments
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

  def apply_omniauth(omniauth)
    unless omniauth['info'].blank?
      self.email = omniauth['info']['email'] if email.blank?
      self.first_name = omniauth['info']['first_name'] if first_name.blank?
      self.last_name = omniauth['info']['last_name'] if last_name.blank?
    end
    authentications.build( provider: omniauth['provider'], uid: omniauth['uid'] )
  end

  def password_required?
    (authentications.empty? || !password.blank?) && super
  end

  private

  def notify_system_admins
    User.current.system_admins.each do |system_admin|
      UserMailer.notify_system_admin(system_admin, self).deliver if Rails.env.production?
    end
  end

  def status_activated
    unless self.new_record? or self.changes.blank?
      if self.changes['status'] and self.changes['status'][1] == 'active'
        UserMailer.status_activated(self).deliver if Rails.env.production?
      end
    end
  end
end
