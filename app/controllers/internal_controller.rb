# frozen_string_literal: true

# Handles search across the internal site.
class InternalController < ApplicationController
  before_action :authenticate_user!

  def search
    @projects = current_user.all_viewable_projects.search(params[:search]).order('name').limit(10)
    @groups = current_user.all_viewable_groups.search(params[:search]).order('description').limit(10)
    @objects = @projects + @groups
    if @objects.empty?
      redirect_to tasks_path(search: params[:search])
    elsif @objects.size == 1
      redirect_to @objects.first
    end
  end

  def update_task_status
    if params[:status] == 'all'
      current_user.update calendar_task_status: nil
    elsif params[:status] == 'completed'
      current_user.update calendar_task_status: true
    else
      current_user.update calendar_task_status: false
    end
    redirect_to month_path
  end
end
