# frozen_string_literal: true

# Allows projects to have editors and viewers.
class ProjectUser < ApplicationRecord
  # Concerns
  include Forkable

  # Model Validation
  validates :project_id, :creator_id, presence: true
  validates :invite_token, uniqueness: true, allow_nil: true

  # Model Relationships
  belongs_to :project
  belongs_to :user
  belongs_to :creator, class_name: 'User', foreign_key: 'creator_id'

  def generate_invite_token!(new_invite_token = SecureRandom.hex(8))
    update invite_token: new_invite_token if invite_token.blank? && ProjectUser.where(invite_token: new_invite_token).count == 0
    send_invite_email_in_background
  end

  def notify_user_added_to_project
    send_added_to_project_email_in_background
  end

  def send_invite_email_in_background
    fork_process(:send_invite_email)
  end

  def send_added_to_project_email_in_background
    fork_process(:send_added_to_project_email)
  end

  private

  def send_invite_email
    return unless EMAILS_ENABLED
    return if invite_token.blank?
    UserMailer.invite_user_to_project(self).deliver_now
  end

  def send_added_to_project_email
    return unless EMAILS_ENABLED
    UserMailer.user_added_to_project(self).deliver_now
  end
end
