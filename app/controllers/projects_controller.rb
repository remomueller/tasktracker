class ProjectsController < ApplicationController
  before_filter :authenticate_user!
  
  def add_comment
    @project = current_user.all_viewable_projects.find_by_id(params[:id])
    if @project and not params[:comment].blank?
      @project.new_comment(current_user, params[:comment])
      render :update do |page|
        @object = @project
        page.replace_html "#{@object.class.name.downcase}_#{@object.id}_comments", :partial => 'comments/index'
      end
    else
      render :nothing => true
    end
  end
  
  def index
    @projects = current_user.all_viewable_projects
  end

  def show
    @project = current_user.all_viewable_projects.find_by_id(params[:id])
    redirect_to root_path unless @project
  end

  def new
    @project = current_user.projects.new
  end

  def edit
    @project = current_user.all_projects.find_by_id(params[:id])
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
