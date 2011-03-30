class ProjectsController < ApplicationController
  before_filter :authenticate_user!
  
  def add_comment
    @project = current_user.all_viewable_projects.find_by_id(params[:id])
    if @project and not params[:comment].blank?
      @project.new_comment(current_user, params[:comment])

      @object = @project
      @position = params[:position]
      @comments = @object.comments
      render "comments/add_comment"
    else
      render :nothing => true
    end
  end
  
  def index
    @projects = current_user.all_viewable_projects.order('name')
  end

  def show
    @project = current_user.all_viewable_projects.find_by_id(params[:id])
    if @project
      @frame = Frame.find_by_id(params[:frame_id] || 'backlog')
      stickies_scope = @project.stickies
      @stickies = stickies_scope.with_frame(params[:frame_id] || 'backlog').order('end_date DESC, start_date DESC').page(params[:page]).per(10)
    else
      redirect_to root_path
    end
  end

  def new
    @project = current_user.projects.new
  end

  def edit
    @project = current_user.all_projects.find_by_id(params[:id])
    redirect_to root_path unless @project
  end

  def create
    params[:project][:start_date] = Date.strptime(params[:project][:start_date], "%m/%d/%Y") if params[:project] and not params[:project][:start_date].blank?
    params[:project][:end_date] = Date.strptime(params[:project][:end_date], "%m/%d/%Y") if params[:project] and not params[:project][:end_date].blank?
    
    @project = current_user.projects.new(params[:project])
    if @project.save
      redirect_to(@project, :notice => 'Project was successfully created.')
    else
      render :action => "new"
    end
  end

  def update
    params[:project][:start_date] = Date.strptime(params[:project][:start_date], "%m/%d/%Y") if params[:project] and not params[:project][:start_date].blank?
    params[:project][:end_date] = Date.strptime(params[:project][:end_date], "%m/%d/%Y") if params[:project] and not params[:project][:end_date].blank?
    
    @project = current_user.all_projects.find_by_id(params[:id])
    if @project
      if @project.update_attributes(params[:project])
        redirect_to(@project, :notice => 'Project was successfully updated.')
      else
        render :action => "edit"
      end
    else
      redirect_to root_path
    end
  end

  def destroy
    @project = current_user.all_projects.find_by_id(params[:id])
    if @project
      @project.destroy
      redirect_to projects_path
    else
      redirect_to root_path
    end
  end
end
