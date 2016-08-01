# frozen_string_literal: true

# Allows projects and related tasks to be viewed.
class ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_viewable_project_or_redirect, only: [:show]
  before_action :find_editable_project_or_redirect, only: [:edit, :update, :destroy, :bulk, :reassign]

  # GET /projects/1/bulk
  def bulk
  end

  # POST /projects/1/reassign
  # POST /projects/1/reassign.js
  def reassign
    original_user_id = User.with_project(@project.id, [true]).find_by_id(params[:from_user_id]).id rescue original_user_id = nil       # Editors only
    reassign_to_user_id = User.with_project(@project.id, [true]).find_by_id(params[:to_user_id]).id rescue reassign_to_user_id = nil     # Editors only
    params[:sticky_status] = 'not_completed' unless ['not_completed', 'completed', 'all'].include?(params[:sticky_status])

    sticky_scope = @project.stickies.where(owner_id: original_user_id)
    if params[:sticky_status] == 'completed'
      sticky_scope = sticky_scope.where(completed: true)
    elsif params[:sticky_status] == 'not_completed'
      sticky_scope = sticky_scope.where(completed: false)
    end
    sticky_scope = sticky_scope.with_tag(params[:tag_id]) unless params[:tag_id].blank?
    @sticky_count = sticky_scope.count

    sticky_scope.update_all(owner_id: reassign_to_user_id)

    respond_to do |format|
      format.html { redirect_to @project, notice: "#{@sticky_count} #{@sticky_count == 1 ? 'Task' : 'Tasks'} successfully reassigned." }
      format.js # reassign.js.erb
    end
  end

  def selection
    @sticky = Sticky.new(params.require(:sticky).permit(:board_id, :owner_id, { tag_ids: [] }))
    @project = current_user.all_projects.find_by_id(params[:sticky][:project_id])
  end

  # GET /projects
  def index
    @order = scrub_order(Project, params[:order], 'projects.name')
    @projects = current_user.all_viewable_projects
                            .by_favorite(current_user.id).order("(project_preferences.favorite IS NULL or project_preferences.favorite = 'f') ASC, #{@order}")
                            .page(params[:page]).per(10)
  end

  # GET /projects/1
  def show
    params[:status] ||= ['planned','completed']
    @template = @project.templates.find_by_id(params[:template_id])

    unless @template
      @board = @project.boards.find_by_name(params[:board])
      params[:board_id] = @board ? @board.id : (params[:board_id] || 0)
      @board = @project.boards.find_by_id(params[:board_id]) unless @board
    end
  end

  # GET /projects/new
  def new
    @project = current_user.projects.new
  end

  # GET /projects/1/edit
  def edit
  end

  # POST /projects
  # POST /projects.js
  def create
    @project = current_user.projects.new(project_params)

    respond_to do |format|
      if @project.save
        format.html { redirect_to(@project, notice: 'Project was successfully created.') }
        format.js do
          @sticky = current_user.stickies.new(due_date: parse_date(params[:due_date]), project_id: @project.id)
          render 'stickies/new'
        end
      else
        format.html { render :new }
        format.js { render :new }
      end
    end
  end

  # PATCH /projects/1
  def update
    if @project.update(project_params)
      redirect_to @project, notice: 'Project was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /projects/1
  def destroy
    @project.destroy
    redirect_to projects_path
  end

  private

  def find_viewable_project_or_redirect
    super(:id)
  end

  # Overwriting application_controller
  def find_editable_project_or_redirect
    super(:id)
  end

  def project_params
    params.require(:project).permit(
      :name, :description
    )
  end
end
