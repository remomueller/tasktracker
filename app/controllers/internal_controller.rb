# frozen_string_literal: true

# Handles search across the internal site.
class InternalController < ApplicationController
  before_action :authenticate_user!

  def search
    @projects = current_user.all_viewable_projects.search(params[:search]).order('name').limit(10)
    @groups = current_user.all_viewable_groups.search(params[:search]).order('description').limit(10)
    @objects = @projects + @groups
    respond_to do |format|
      format.json { render json: ([params[:search]] + @projects.collect(&:name)).uniq }
      format.html do
        if @objects.empty?
          redirect_to tasks_path(search: params[:search])
        elsif @objects.size == 1
          redirect_to @objects.first
        end
      end
    end
  end
end
