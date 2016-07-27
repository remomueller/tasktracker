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
    redirect_to month_path(date: params[:date])
  end

  def toggle_tag_selection
    tag_filter = current_user.tag_filters.find_by tag_id: params[:tag_id]
    if tag_filter
      tag_filter.destroy
    elsif params[:tag_id].blank?
      current_user.tag_filters.destroy_all
    else
      current_user.tag_filters.create(tag_id: params[:tag_id])
    end
    redirect_to month_path(date: params[:date])
  end

  def toggle_owner_selection
    owner_filter = current_user.owner_filters.find_by owner_id: params[:owner_id]
    if owner_filter
      owner_filter.destroy
    elsif params[:owner_id].blank?
      current_user.owner_filters.destroy_all
    else
      current_user.owner_filters.create(owner_id: params[:owner_id])
    end
    redirect_to month_path(date: params[:date])
  end

  def toggle_project_selection
    project_filter = current_user.project_filters.find_by project_id: params[:project_id]
    if project_filter
      project_filter.destroy
    elsif params[:project_id].blank?
      current_user.project_filters.destroy_all
    else
      current_user.project_filters.create(project_id: params[:project_id])
    end
    redirect_to month_path(date: params[:date])
  end
end
