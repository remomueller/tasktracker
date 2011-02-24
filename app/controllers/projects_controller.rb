class ProjectsController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    @projects = current_user.all_projects
  end

  def show
    @project = current_user.all_projects.find(params[:id])
    redirect_to root_path unless @project
  end

  def new
    @project = current_user.projects.new
  end

  def edit
    @project = current_user.all_projects.find(params[:id])
    redirect_to root_path unless @project
  end

  def create
    @project = current_user.projects.new(params[:project])
    if @project.save
      redirect_to(@project, :notice => 'Project was successfully created.')
    else
      render :action => "new"
    end
  end

  def update
    @project = current_user.all_projects.find(params[:id])
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
    @project = current_user.all_projects.find(params[:id])
    if @project
      @project.destroy
      redirect_to projects_path
    else
      redirect_to root_path
    end
  end
end
