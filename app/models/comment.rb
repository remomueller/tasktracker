# frozen_string_literal: true

# Allows commenting on tasks.
class Comment < ApplicationRecord
  # Concerns
  include Deletable, Searchable

  # Scopes
  scope :with_project, -> (arg) { where('comments.sticky_id in (select stickies.id from stickies where stickies.deleted = ? and stickies.project_id IN (?))', false, arg) }

  # Model Validation
  validates :description, :sticky_id, :user_id, presence: true

  # Model Relationships
  belongs_to :user
  belongs_to :sticky, touch: true
  has_many :notifications

  delegate :project, to: :sticky
  delegate :project_id, to: :sticky

  # Model Methods
  def name
    "##{id}"
  end

  def self.searchable_attributes
    %w(description)
  end

  # TODO: Change to editable_by?
  def modifiable_by?(current_user)
    # current_user.all_projects.pluck(:id).include?(self.sticky.project_id)
    sticky.project.modifiable_by?(current_user)
  end

  def deletable_by?(current_user)
    user == current_user || modifiable_by?(current_user)
  end

  def create_notifications!
    sticky.users_to_notify.where.not(id: user_id).find_each do |u|
      notification = u.notifications.where(project_id: project_id, comment_id: id).first_or_create
      notification.mark_as_unread!
    end
  end

  def destroy
    super
    notifications.destroy_all
  end
end
