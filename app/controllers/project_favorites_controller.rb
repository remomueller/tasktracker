class ProjectFavoritesController < ApplicationController
  before_action :authenticate_user!

  # # GET /project_favorites
  # # GET /project_favorites.xml
  # def index
  #   @project_favorites = ProjectFavorite.all
  #
  #   respond_to do |format|
  #     format.html # index.html.erb
  #     format.xml  { render xml: @project_favorites }
  #   end
  # end
  #
  # # GET /project_favorites/1
  # # GET /project_favorites/1.xml
  # def show
  #   @project_favorite = ProjectFavorite.find(params[:id])
  #
  #   respond_to do |format|
  #     format.html # show.html.erb
  #     format.xml  { render xml: @project_favorite }
  #   end
  # end
  #
  # # GET /project_favorites/new
  # # GET /project_favorites/new.xml
  # def new
  #   @project_favorite = ProjectFavorite.new
  #
  #   respond_to do |format|
  #     format.html # new.html.erb
  #     format.xml  { render xml: @project_favorite }
  #   end
  # end
  #
  # # GET /project_favorites/1/edit
  # def edit
  #   @project_favorite = ProjectFavorite.find(params[:id])
  # end
  #
  # # POST /project_favorites
  # # POST /project_favorites.xml
  # def create
  #   @project_favorite = ProjectFavorite.new(params[:project_favorite])
  #
  #   respond_to do |format|
  #     if @project_favorite.save
  #       format.html { redirect_to(@project_favorite, notice: 'Project favorite was successfully created.') }
  #       format.xml  { render xml: @project_favorite, status: :created, location: @project_favorite }
  #     else
  #       format.html { render action: "new" }
  #       format.xml  { render xml: @project_favorite.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end
  #
  # # PUT /project_favorites/1
  # # PUT /project_favorites/1.xml
  # def update
  #   @project_favorite = ProjectFavorite.find(params[:id])
  #
  #   respond_to do |format|
  #     if @project_favorite.update_attributes(params[:project_favorite])
  #       format.html { redirect_to(@project_favorite, notice: 'Project favorite was successfully updated.') }
  #       format.xml  { head :ok }
  #     else
  #       format.html { render action: "edit" }
  #       format.xml  { render xml: @project_favorite.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end
  #
  # # DELETE /project_favorites/1
  # # DELETE /project_favorites/1.xml
  # def destroy
  #   @project_favorite = ProjectFavorite.find(params[:id])
  #   @project_favorite.destroy
  #
  #   respond_to do |format|
  #     format.html { redirect_to(project_favorites_url) }
  #     format.xml  { head :ok }
  #   end
  # end
end
