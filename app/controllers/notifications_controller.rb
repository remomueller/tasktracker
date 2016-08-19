# frozen_string_literal: true

# Allows users to be notified inside the web application of completion of tasks
# and creation of comments.
class NotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_notification_or_redirect, only: [:show, :update]
  before_action :set_viewable_project, only: [:mark_all_as_read]

  # GET /notifications
  def index
    @notifications = if params[:all] == '1'
                       current_user.notifications.where('notifications.created_at > ?', Time.zone.now - 7.days)
                     else
                       current_user.notifications.where(read: false)
                     end
  end

  # GET /notifications/1
  def show
    @notification.update read: true
    redirect_to notification_redirect_path
  end

  # PATCH /notifications/1.js
  def update
    @notification.update(notification_params)
    render :show
  end

  # PATCH /notifications/mark_all_as_read
  def mark_all_as_read
    if @project
      @notifications = current_user.notifications.where(project_id: @project.id)
      @notifications.update_all read: true
    else
      @notifications = Notification.none
    end
  end

  private

  def find_notification_or_redirect
    @notification = current_user.notifications.find_by_id params[:id]
    redirect_to notifications_path unless @notification
  end

  def notification_params
    params.require(:notification).permit(:read)
  end

  def notification_redirect_path
    return @notification.comment.sticky if @notification.comment
    return @notification.sticky if @notification.sticky
    notifications_path
  end
end
