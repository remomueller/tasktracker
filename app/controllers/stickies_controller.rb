class StickiesController < ApplicationController
  before_filter :authenticate_user!

  def add_comment
    @sticky = current_user.all_viewable_stickies.find_by_id(params[:id])
    if @sticky and not params[:comment].blank?
      @sticky.new_comment(current_user, params[:comment])

      @object = @sticky
      @position = params[:position]
      @comments = @object.comments
      render "comments/add_comment"
    else
      render :nothing => true
    end
  end

  def search
    current_user.update_attribute :stickies_per_page, params[:stickies_per_page].to_i if params[:stickies_per_page].to_i >= 10 and params[:stickies_per_page].to_i <= 200
    @project = current_user.all_viewable_projects.find_by_id(params[:project_id])
    if @project
      @frame = Frame.find_by_id(params[:frame_id])
      stickies_scope = @project.stickies
      @stickies = stickies_scope.with_frame(params[:frame_id]).order("(status = 'completed') ASC, (status = 'ongoing') DESC, end_date DESC, start_date DESC").page(params[:page]).per(current_user.stickies_per_page)
      render "projects/show"
    else
      redirect_to root_path
    end
  end
    
  def index
    current_user.update_attribute :stickies_per_page, params[:stickies_per_page].to_i if params[:stickies_per_page].to_i >= 10 and params[:stickies_per_page].to_i <= 200
    stickies_scope = current_user.all_viewable_stickies
    @search_terms = params[:search].to_s.gsub(/[^0-9a-zA-Z]/, ' ').split(' ')
    @search_terms.each{|search_term| stickies_scope = stickies_scope.search(search_term) }
    @stickies = stickies_scope.page(params[:page]).per(current_user.stickies_per_page)
  end

  def show
    @sticky = current_user.all_viewable_stickies.find_by_id(params[:id])
    redirect_to root_path unless @sticky
  end

  def new
    @sticky = current_user.stickies.new(params[:sticky])
    @project_id = @sticky.project_id
  end

  def edit
    @sticky = current_user.all_stickies.find_by_id(params[:id])
    @project_id = @sticky.project_id
    redirect_to root_path unless @sticky
  end

  def create
    params[:sticky][:start_date] = Date.strptime(params[:sticky][:start_date], "%m/%d/%Y") if params[:sticky] and not params[:sticky][:start_date].blank?
    params[:sticky][:end_date] = Date.strptime(params[:sticky][:end_date], "%m/%d/%Y") if params[:sticky] and not params[:sticky][:end_date].blank?
    
    @sticky = current_user.stickies.new(params[:sticky])
    if @sticky.save
      redirect_to(@sticky, :notice => 'Sticky was successfully created.')
    else
      render :action => "new"
    end
  end

  def update
    params[:sticky][:start_date] = Date.strptime(params[:sticky][:start_date], "%m/%d/%Y") if params[:sticky] and not params[:sticky][:start_date].blank?
    params[:sticky][:end_date] = Date.strptime(params[:sticky][:end_date], "%m/%d/%Y") if params[:sticky] and not params[:sticky][:end_date].blank?
    
    @sticky = current_user.all_stickies.find_by_id(params[:id])
    if @sticky
      if @sticky.update_attributes(params[:sticky])
        redirect_to(@sticky, :notice => 'Sticky was successfully updated.')
      else
        render :action => "edit"
      end
    else
      redirect_to root_path
    end
  end

  def destroy
    @sticky = current_user.all_stickies.find_by_id(params[:id])
    if @sticky
      @sticky.destroy
      redirect_to stickies_path
    else
      redirect_to root_path
    end
  end
end
