class ProjectUser < ActiveRecord::Base
  # attr_accessible :user_id, :invite_email, :creator_id, :allow_editing, :invite_token

  # Model Validation
  validates :project_id, :creator_id, presence: true
  validates :invite_token, uniqueness: true, allow_nil: true

  # Model Relationships
  belongs_to :project
  belongs_to :user
  belongs_to :creator, class_name: 'User', foreign_key: 'creator_id'

  def generate_invite_token!(new_invite_token = SecureRandom.hex(64))
    update invite_token: new_invite_token if respond_to?('invite_token') && invite_token.blank? && ProjectUser.where(invite_token: new_invite_token).count == 0
    UserMailer.invite_user_to_project(self).deliver_later if EMAILS_ENABLED && !invite_token.blank?
  end

  def notify_user_added_to_project
    UserMailer.user_added_to_project(self).deliver_later if EMAILS_ENABLED
  end
end
