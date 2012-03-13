class StickiesController < ApplicationController
  before_filter :authenticate_user!

  def calendar
    if params[:save_settings] == '1'
      user_settings = current_user.settings
      user_settings[:calendar_status] = params[:status] || []
      user_settings[:assigned_to_me] = (params[:assigned_to_me] == '1') ? '1' : '0'
      current_user.update_attribute :settings, user_settings
    else
      params[:status] = current_user.settings[:calendar_status] || []
      params[:assigned_to_me] = (current_user.settings[:assigned_to_me] == '1') ? '1' : '0'
    end

    @selected_date = begin Date.strptime(params[:selected_date], "%m/%d/%Y") rescue Date.today end
    @start_date = @selected_date.beginning_of_month
    @end_date = @selected_date.end_of_month

    @first_sunday = @start_date - @start_date.wday.day
    @last_saturday = @end_date + (6 - @end_date.wday).day

    sticky_scope = current_user.all_viewable_stickies.where(completed: (params[:status] || []).collect{|v| (v.to_s == 'completed')})

    sticky_scope = sticky_scope.with_project(current_user.all_viewable_projects.collect{|p| p.id} - current_user.hidden_project_ids, current_user.id)

    sticky_scope = sticky_scope.where(owner_id: current_user.id) if params[:assigned_to_me] == '1'

    case params[:date_type] when 'start_date'
      sticky_scope = sticky_scope.with_start_date_for_calendar(@first_sunday, @last_saturday)
    when 'end_date'
      sticky_scope = sticky_scope.with_end_date_for_calendar(@first_sunday, @last_saturday)
    else
      sticky_scope = sticky_scope.with_due_date_for_calendar(@first_sunday, @last_saturday)
    end
    @stickies = sticky_scope
  end

  def search
    current_user.update_attribute :stickies_per_page, params[:stickies_per_page].to_i if params[:stickies_per_page].to_i >= 10 and params[:stickies_per_page].to_i <= 200
    if @project = current_user.all_viewable_projects.find_by_id(params[:project_id])
      @frame = Frame.find_by_id(params[:frame_id])
      @order = Sticky.column_names.collect{|column_name| "stickies.#{column_name}"}.include?(params[:order].to_s.split(' ').first) ? params[:order] : "completed, due_date, end_date DESC, start_date DESC"
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
    @order = Sticky.column_names.collect{|column_name| "stickies.#{column_name}"}.include?(params[:order].to_s.split(' ').first) ? params[:order] : "completed, due_date, end_date DESC, start_date DESC"
    sticky_scope = current_user.all_viewable_stickies

    sticky_scope = sticky_scope.with_owner(params[:owner_id]) unless params[:owner_id].blank?

    @start_date = begin Date.strptime(params[:due_date_start_date], "%m/%d/%Y") rescue nil end
    @end_date = begin Date.strptime(params[:due_date_end_date], "%m/%d/%Y") rescue nil end
    sticky_scope = sticky_scope.due_date_within(@start_date, @end_date)

    sticky_scope = sticky_scope.where(completed: (params[:status] || []).collect{|v| (v.to_s == 'completed')})

    sticky_scope = sticky_scope.with_project(params[:project_id], current_user.id) unless params[:project_id].blank?

    sticky_scope = sticky_scope.where("stickies.owner_id IS NOT NULL") if params[:unnassigned].to_s != '1'

    unless params[:tag_names].blank?
      if params[:tag_filter] == 'any'
        sticky_scope = sticky_scope.with_tag_name(params[:tag_names])
      elsif params[:tag_filter] == 'all'
        params[:tag_names].each do |tag_name|
          sticky_scope = sticky_scope.with_tag_name(tag_name)
        end
      end
    end

    @search_terms = params[:search].to_s.gsub(/[^0-9a-zA-Z]/, ' ').split(' ')
    @search_terms.each{|search_term| sticky_scope = sticky_scope.search(search_term) }
    sticky_scope = sticky_scope.order(@order)
    @sticky_count = sticky_scope.count

    if params[:format] == 'csv'
      @csv_string = CSV.generate do |csv|
        csv << ["Name", "Due Date", "Description", "Status", "Assigned To", "Tags", "Project", "Creator", "Frame"]
        sticky_scope.each do |sticky|
          csv << [sticky.name,
                  sticky.due_date.blank? ? '' : sticky.due_date.strftime("%m-%d-%Y"),
                  sticky.description,
                  sticky.completed? ? 'completed' : '',
                  sticky.owner ? sticky.owner.name : '',
                  sticky.tags.collect{|t| t.name}.join('; '),
                  sticky.project.name,
                  sticky.user.name,
                  sticky.frame ? sticky.frame.name : '']
        end
      end
      send_data @csv_string, type: 'text/csv; charset=iso-8859-1; header=present',
                            disposition: "attachment; filename=\"Stickies #{Time.now.strftime("%Y.%m.%d %Ih%M %p")}.csv\""
      return
    elsif params[:format] == 'ics'
      @ics_string = RiCal.Calendar do |cal|
        sticky_scope.each do |sticky|
          sticky.export_ics_block_evt(cal)
        end
      end.to_s
      send_data @ics_string, type: 'text/calendar', disposition: "attachment; filename=\"stickies.ics\""
      return
    end
    @stickies = sticky_scope.page(params[:page]).per(current_user.stickies_per_page)
  end

  def show
    @sticky = current_user.all_viewable_stickies.find_by_id(params[:id])
    redirect_to root_path unless @sticky
  end

  def popup
    @sticky = current_user.all_viewable_stickies.find_by_id(params[:id])
    render nothing: true unless @sticky
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

    # params[:sticky][:due_date] = Date.strptime(params[:sticky][:due_date], "%m/%d/%Y") if params[:sticky] and not params[:sticky][:due_date].blank?

    params[:sticky] ||= {}
    params[:sticky][:due_date] = Date.strptime(params[:sticky][:due_date], "%m/%d/%Y") unless params[:sticky][:due_date].blank?

    params[:sticky][:all_day] = begin
      unless params[:sticky][:due_at_string].blank?
      t = Time.parse(params[:sticky][:due_at_string])
      params[:sticky][:due_date] = Time.parse(params[:sticky][:due_date].strftime("%Y-%m-%d ") + params[:sticky][:due_at_string])
      false
      else
        true
      end
    rescue
      true
    end

    @sticky = current_user.stickies.new(params[:sticky])
    if @sticky.save
      flash[:notice] = 'Sticky was successfully created.'
      if params[:from_calendar] == '1'
        # redirect_to calendar_stickies_path(selected_date: @sticky.due_date.blank? ? '' : @sticky.due_date.strftime('%m/%d/%Y'))
        # Will render create.js instead
        render 'create'
      else
        redirect_to @sticky
      end
    else
      @project_id = @sticky.project_id
      render "new"
    end
  end

  def move
    params[:due_date] = Date.strptime(params[:due_date], "%m/%d/%Y") unless params[:due_date].blank?

    @sticky = current_user.all_stickies.find_by_id(params[:id])

    params[:due_date] = Time.parse(params[:due_date].strftime("%Y-%m-%d ") + @sticky.due_at_string) rescue ''

    if @sticky and not params[:due_date].blank?
      @sticky.update_attribute :due_date, params[:due_date]
    else
      @sticky = current_user.all_viewable_stickies.find_by_id(params[:id])
    end
    if @sticky
      render 'create'
    else
      render nothing: true
    end
  end

  def update
    params[:sticky] ||= {}
    params[:sticky][:due_date] = Date.strptime(params[:sticky][:due_date], "%m/%d/%Y") unless params[:sticky][:due_date].blank?

    params[:sticky][:all_day] = begin
      unless params[:sticky][:due_at_string].blank?
      t = Time.parse(params[:sticky][:due_at_string])
      params[:sticky][:due_date] = Time.parse(params[:sticky][:due_date].strftime("%Y-%m-%d ") + params[:sticky][:due_at_string])
      false
      else
        true
      end
    rescue
      true
    end

    params[:sticky][:tag_ids] ||= [] if params[:sticky]
    @sticky = current_user.all_stickies.find_by_id(params[:id])
    if @sticky
      original_due_date = @sticky.due_date
      if @sticky.update_attributes(params[:sticky])
        flash[:notice] = 'Sticky was successfully updated.'

        @sticky.shift_group(((@sticky.due_date - original_due_date) / 1.day).round, params[:shift]) if not original_due_date.blank? and not @sticky.due_date.blank?

        if params[:from_calendar] == '1'
          redirect_to calendar_stickies_path(selected_date: @sticky.due_date.blank? ? '' : @sticky.due_date.strftime('%m/%d/%Y'))
        else
          redirect_to @sticky
        end
      else
        @project_id = @sticky.project_id
        render action: "edit"
      end
    else
      redirect_to root_path
    end
  end

  def destroy
    @sticky = current_user.all_stickies.find_by_id(params[:id])
    if @sticky
      if @sticky.group and params[:discard] == 'following'
        @sticky.group.stickies.where('due_date >= ?', @sticky.due_date).destroy_all
      elsif @sticky.group and params[:discard] == 'all'
        @sticky.group.destroy
      else # 'single'
        @sticky.destroy
      end

      respond_to do |format|
        format.html do
          flash[:notice] = 'Sticky was successfully deleted.'
          if params[:from_calendar] == '1'
            redirect_to calendar_stickies_path(selected_date: @sticky.due_date.blank? ? '' : @sticky.due_date.strftime('%m/%d/%Y'))
          else
            redirect_to stickies_path
          end
        end
        format.js  { render 'destroy' }
      end
    else
      respond_to do |format|
        format.html { redirect_to root_path }
        format.js { render nothing: true }
      end
    end
  end
end
