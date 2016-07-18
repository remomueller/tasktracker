# frozen_string_literal: true

# Allows projects to be favorited.
class ProjectFavoritesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_viewable_project_or_redirect

  # POST /project_favorites/1/colorpicker
  def colorpicker
    project_favorite = @project.project_favorites.where(user_id: current_user.id).first_or_create
    project_favorite.update color: params[:color]
    head :ok
  end

  # POST /project_favorites/1/colorpicker
  def favorite
    project_favorite = @project.project_favorites.where(user_id: current_user.id).first_or_create
    project_favorite.update favorite: (params[:favorite] == '1')
  end
end
