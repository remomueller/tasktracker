# frozen_string_literal: true

# Allows tasks to be tagged and filtered.
class TagsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_viewable_project, only: [:index]
  before_action :set_editable_project, only: [:add_stickies]
  before_action :redirect_without_project, only: [:add_stickies]
  before_action :set_viewable_tag, only: [:show]
  before_action :set_editable_tag, only: [:edit, :update, :destroy]
  before_action :redirect_without_tag, only: [:show, :edit, :update, :destroy]

  def add_stickies
    @tag = current_user.all_tags.find_by_id(params[:tag_id])
    @stickies = @project.stickies.where(id: params[:sticky_ids].split(',')) if @project

    if @tag && @stickies.size > 0
      if @stickies.collect{|s| s.tags.where(id: @tag.id)}.flatten.size == @stickies.size
        @stickies.each do |s|
          s.tags.delete(@tag)
        end
      else
        @stickies.each do |s|
          s.tags << @tag unless s.tags.include?(@tag)
        end
      end
    else
      head :ok
    end
  end

  # GET /tags
  def index
    @order = scrub_order(Tag, params[:order], 'tags.name')
    @tags = current_user.all_viewable_tags.search(params[:search]).filter(params).order(@order).page(params[:page]).per( 40 )
  end

  # GET /tags/1
  def show
  end

  # GET /tags/new
  def new
    @tag = current_user.tags.new(tag_params)
  end

  # GET /tags/1/edit
  def edit
  end

  # POST /tags
  def create
    @tag = current_user.tags.new(tag_params)
    if @tag.save
      redirect_to @tag, notice: 'Tag was successfully created.'
    else
      render :new
    end
  end

  # PATCH /tags/1
  def update
    if @tag.update(tag_params)
      redirect_to @tag, notice: 'Tag was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /tags/1
  def destroy
    @tag.destroy
    redirect_to tags_path(project_id: @tag.project_id)
  end

  private

  def set_viewable_tag
    @tag = current_user.all_viewable_tags.find_by_id(params[:id])
  end

  def set_editable_tag
    @tag = current_user.all_tags.find_by_id(params[:id])
  end

  def redirect_without_tag
    empty_response_or_root_path(tags_path) unless @tag
  end

  def tag_params
    params[:tag] ||= { blank: '1' }

    unless params[:tag][:project_id].blank?
      project = current_user.all_projects.find_by_id(params[:tag][:project_id])
      params[:tag][:project_id] = project ? project.id : nil
    end

    params.require(:tag).permit(
      :name, :description, :color, :project_id
    )
  end
end
