# frozen_string_literal: true

# Allows projects to be favorited.
class ProjectFavoritesController < ApplicationController
  before_action :authenticate_user!
end
