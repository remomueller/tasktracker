class StickiesController < ApplicationController
  before_filter :authenticate_user!

  def calendar
    @selected_date = begin Date.strptime(params[:selected_date], "%m/%d/%Y") rescue Date.today end
    @start_date = @selected_date.beginning_of_month
    @end_date = @selected_date.end_of_month
    
    @first_sunday = @start_date - @start_date.wday.day
    @last_saturday = @end_date + (6 - @end_date.wday).day
    
    sticky_scope = current_user.all_viewable_stickies.status((params[:status_selected] || {}).collect{|k,v| k.to_s})
    
    case params[:date_type] when 'start_date'
      sticky_scope = sticky_scope.with_start_date_for_calendar(@start_date, @end_date)
    when 'end_date'
      sticky_scope = sticky_scope.with_end_date_for_calendar(@start_date, @end_date)
    else
      sticky_scope = sticky_scope.with_due_date_for_calendar(@start_date, @end_date)
    end
    @stickies = sticky_scope
  end

  def search
    current_user.update_attribute :stickies_per_page, params[:stickies_per_page].to_i if params[:stickies_per_page].to_i >= 10 and params[:stickies_per_page].to_i <= 200
    if @project = current_user.all_viewable_projects.find_by_id(params[:project_id])
      @frame = Frame.find_by_id(params[:frame_id])
      @order = Sticky.column_names.collect{|column_name| "stickies.#{column_name}"}.include?(params[:order].to_s.split(' ').first) ? params[:order] : "(status = 'completed') ASC, (status = 'ongoing') DESC, due_date ASC, end_date DESC, start_date DESC"
      sticky_scope = @project.stickies.with_frame(params[:frame_id])
      sticky_scope = sticky_scope.order(@order)
      @stickies = sticky_scope.page(params[:page]).per(current_user.stickies_per_page)
      render "projects/show"
    elsif @group = current_user.all_viewable_groups.find_by_id(params[:group_id])
      @order = Sticky.column_names.collect{|column_name| "stickies.#{column_name}"}.include?(params[:order].to_s.split(' ').first) ? params[:order] : "stickies.due_date"
      sticky_scope = @group.stickies
      sticky_scope = sticky_scope.order(@order)
      @stickies = sticky_scope.page(params[:page]).per(current_user.stickies_per_page)
    else
      redirect_to root_path
    end
  end
    
  def index
    current_user.update_attribute :stickies_per_page, params[:stickies_per_page].to_i if params[:stickies_per_page].to_i >= 10 and params[:stickies_per_page].to_i <= 200
    @order = Sticky.column_names.collect{|column_name| "stickies.#{column_name}"}.include?(params[:order].to_s.split(' ').first) ? params[:order] : "(status = 'completed') ASC, (status = 'ongoing') DESC, due_date ASC, end_date DESC, start_date DESC"
    sticky_scope = current_user.all_viewable_stickies
    @search_terms = params[:search].to_s.gsub(/[^0-9a-zA-Z]/, ' ').split(' ')
    @search_terms.each{|search_term| sticky_scope = sticky_scope.search(search_term) }
    sticky_scope = sticky_scope.order(@order)
    @stickies = sticky_scope.page(params[:page]).per(current_user.stickies_per_page)
  end

  def show
    @sticky = current_user.all_viewable_stickies.find_by_id(params[:id])
    redirect_to root_path unless @sticky
  end

  def new
    @sticky = current_user.stickies.new(params[:sticky])
    @sticky.project = current_user.all_projects.first if not @sticky.project and current_user.all_projects.size == 1
    @project_id = @sticky.project_id
  end

  def edit
    if @sticky = current_user.all_stickies.find_by_id(params[:id])
      @project_id = @sticky.project_id
    else
      if @sticky = current_user.all_viewable_stickies.find_by_id(params[:id])
        redirect_to @sticky
      else
        redirect_to root_path
      end
    end
  end

  def create
    params[:sticky][:due_date] = Date.strptime(params[:sticky][:due_date], "%m/%d/%Y") if params[:sticky] and not params[:sticky][:due_date].blank?
    @sticky = current_user.stickies.new(params[:sticky])
    if @sticky.save
      flash[:notice] = 'Sticky was successfully created.'
      if params[:from_calendar] == '1'
        redirect_to calendar_stickies_path(selected_date: @sticky.due_date.blank? ? '' : @sticky.due_date.strftime('%m/%d/%Y'))
      else
        redirect_to @sticky
      end
    else
      @project_id = @sticky.project_id
      render :action => "new"
    end
  end

  def update
    params[:sticky][:due_date]   = Date.strptime(params[:sticky][:due_date], "%m/%d/%Y") if params[:sticky] and not params[:sticky][:due_date].blank?
    @sticky = current_user.all_stickies.find_by_id(params[:id])
    if @sticky
      if @sticky.update_attributes(params[:sticky])
        flash[:notice] = 'Sticky was successfully updated.'
        if params[:from_calendar] == '1'
          redirect_to calendar_stickies_path(selected_date: @sticky.due_date.blank? ? '' : @sticky.due_date.strftime('%m/%d/%Y'))
        else
          redirect_to @sticky
        end
      else
        @project_id = @sticky.project_id
        render :action => "edit"
      end
    else
      redirect_to root_path
    end
  end

  def destroy
    @sticky = current_user.all_stickies.find_by_id(params[:id])
    if @sticky
      if @sticky.group and params[:discard] == 'following'
        @sticky.group.stickies.where('DATE(due_date) >= ?', @sticky.due_date).destroy_all
      elsif @sticky.group and params[:discard] == 'all'
        @sticky.group.destroy
      else # 'single'
        @sticky.destroy
      end
      
      flash[:notice] = 'Sticky was successfully deleted.'
      if params[:from_calendar] == '1'
        redirect_to calendar_stickies_path(selected_date: @sticky.due_date.blank? ? '' : @sticky.due_date.strftime('%m/%d/%Y'))
      else
        redirect_to stickies_path
      end
    else
      redirect_to root_path
    end
  end
end
