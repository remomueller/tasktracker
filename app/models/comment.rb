class Comment < ActiveRecord::Base

  # Concerns
  include Deletable

  # Named Scopes
  scope :search, lambda { |arg| where('LOWER(description) LIKE ?', arg.to_s.downcase.gsub(/^| |$/, '%')) }
  scope :with_creator, lambda { |arg|  where(user_id: arg) }
  scope :with_date_for_calendar, lambda { |*args| where("DATE(comments.created_at) >= ? and DATE(comments.created_at) <= ?", args.first, args[1]) }
  scope :with_project, lambda { |arg| where('comments.sticky_id in (select stickies.id from stickies where stickies.deleted = ? and stickies.project_id IN (?))', false, arg) }

  after_create :send_email

  # Model Validation
  validates_presence_of :description, :sticky_id, :user_id

  # Model Relationships
  belongs_to :user
  belongs_to :sticky, touch: true

  def name
    "##{self.id}"
  end

  def users_to_email(action, project_id, sticky)
    result = (sticky.comments.collect{|c| c.user} + [sticky.user, sticky.owner]).compact.uniq
    result = result.select{|u| u.email_on?(:send_email) and u.email_on?(action) and u.email_on?("project_#{project_id}") and u.email_on?("project_#{project_id}_#{action}") }
  end

  def project_id
    self.sticky.project_id if self.sticky
  end

  def modifiable_by?(current_user)
    # current_user.all_projects.pluck(:id).include?(self.sticky.project_id)
    self.sticky.project.modifiable_by?(current_user)
  end

  def deletable_by?(current_user)
    self.user == current_user or self.modifiable_by?(current_user)
  end

  private

  def send_email
    all_users = []
    all_users = self.sticky.project.users_to_email(:sticky_comments) - [self.user] if self.sticky

    all_users.each do |user_to_email|
      UserMailer.comment_by_mail(self, self.sticky, user_to_email).deliver_later if Rails.env.production?
    end
  end

end
