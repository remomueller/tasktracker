# frozen_string_literal: true

# Allows projects to be favorited.
class ProjectFavoritesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_viewable_project_or_redirect
  before_action :find_or_create_project_favorite

  # POST /project_favorites/1/colorpicker
  def colorpicker
    @project_favorite.update project_favorite_params
    head :ok
  end

  # PATCH /project_favorites/update?project_id=1
  def update
    @project_favorite.update project_favorite_params
  end

  private

  def project_favorite_params
    params.permit(:color, :favorite, :emails_enabled)
  end

  def find_or_create_project_favorite
    @project_favorite = @project.project_favorites.where(user_id: current_user.id).first_or_create
  end
end
