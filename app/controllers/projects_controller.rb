class ProjectsController < ApplicationController
  before_filter :authenticate_user!
  
  def favorite
    @project = current_user.all_viewable_projects.find_by_id(params[:id])
    if @project
      project_favorite = @project.project_favorites.find_or_create_by_user_id(current_user.id)
      project_favorite.update_attribute :favorite, (params[:favorite] == '1')
      # render :nothing => true
    else
      render :nothing => true
    end
  end
  
  def selection
    @sticky = Sticky.new
    @project = current_user.all_projects.find_by_id(params[:sticky][:project_id])
    if @project
      @project_id = @project.id
    else
      render :nothing => true
    end
  end
  
  def index
    current_user.update_attribute :projects_per_page, params[:projects_per_page].to_i if params[:projects_per_page].to_i >= 5 and params[:projects_per_page].to_i <= 20
    
    @order = params[:order].blank? ? 'projects.name' : params[:order]
    projects_scope = current_user.all_viewable_projects
    
    @search_terms = params[:search].to_s.gsub(/[^0-9a-zA-Z]/, ' ').split(' ')
    @search_terms.each{|search_term| projects_scope = projects_scope.search(search_term) }
    
    projects_scope = projects_scope.by_favorite(current_user.id)
    projects_scope = projects_scope.order("(favorite IS NULL or favorite = '0') ASC, " + @order)
    @projects = projects_scope.page(params[:page]).per(current_user.projects_per_page)
  end

  def show
    @project = current_user.all_viewable_projects.find_by_id(params[:id])
    if @project
      @frame = @project.frames.find_by_id(params[:frame_id] || 0)
      unless @frame
        @frame = @project.frames.active_today.first
        params[:frame_id] = @frame.id if @frame
      end
      stickies_scope = @project.stickies
      @stickies = stickies_scope.with_frame(params[:frame_id] || 0).order('end_date DESC, start_date DESC').page(params[:page]).per(10)
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
