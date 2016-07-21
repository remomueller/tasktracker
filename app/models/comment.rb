# frozen_string_literal: true

# Allows commenting on tasks.
class Comment < ActiveRecord::Base
  # Concerns
  include Deletable, Forkable

  # Named Scopes
  scope :search, lambda { |arg| where('LOWER(description) LIKE ?', arg.to_s.downcase.gsub(/^| |$/, '%')) }
  scope :with_creator, lambda { |arg|  where(user_id: arg) }
  scope :with_date_for_calendar, lambda { |*args| where("DATE(comments.created_at) >= ? and DATE(comments.created_at) <= ?", args.first, args[1]) }
  scope :with_project, lambda { |arg| where('comments.sticky_id in (select stickies.id from stickies where stickies.deleted = ? and stickies.project_id IN (?))', false, arg) }

  # Model Validation
  validates :description, :sticky_id, :user_id, presence: true

  # Model Relationships
  belongs_to :user
  belongs_to :sticky, touch: true

  def name
    "##{id}"
  end

  def users_to_email(action, project_id, sticky)
    result = (sticky.comments.collect{|c| c.user} + [sticky.user, sticky.owner]).compact.uniq
    result = result.select{|u| u.email_on?(:send_email) && u.email_on?(action) && u.email_on?("project_#{project_id}") && u.email_on?("project_#{project_id}_#{action}") }
  end

  # TODO: Change to delegate? Comments may always have associated stickies.
  def project_id
    sticky.project_id if sticky
  end

  def modifiable_by?(current_user)
    # current_user.all_projects.pluck(:id).include?(self.sticky.project_id)
    sticky.project.modifiable_by?(current_user)
  end

  def deletable_by?(current_user)
    user == current_user || modifiable_by?(current_user)
  end

  def send_email_in_background
    fork_process(:send_email)
  end

  private

  def send_email
    return unless EMAILS_ENABLED
    all_users = []
    all_users = sticky.project.users_to_email(:sticky_comments) - [user] if sticky
    all_users.each do |user_to_email|
      UserMailer.comment_by_mail(self, sticky, user_to_email).deliver_now
    end
  end
end
