class StickiesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :api_authentication!, only: [:index, :show, :create, :update]

  def calendar
    if params[:save_settings] == '1'
      user_settings = current_user.settings
      user_settings[:calendar_status] = params[:status] || []
      user_settings[:assigned_to_me] = (params[:assigned_to_me] == '1') ? '1' : '0'
      current_user.update_attributes settings: user_settings
    else
      params[:status] = current_user.settings[:calendar_status] || []
      params[:assigned_to_me] = (current_user.settings[:assigned_to_me] == '1') ? '1' : '0'
    end

    @selected_date = parse_date(params[:selected_date], Date.today)
    @start_date = @selected_date.beginning_of_month
    @end_date = @selected_date.end_of_month

    @first_sunday = @start_date - @start_date.wday.day
    @last_saturday = @end_date + (6 - @end_date.wday).day

    sticky_scope = current_user.all_viewable_stickies.where(completed: (params[:status] || []).collect{|v| (v.to_s == 'completed')})

    sticky_scope = sticky_scope.where(project_id: (current_user.all_viewable_projects.collect{|p| p.id} - current_user.hidden_project_ids))

    sticky_scope = sticky_scope.where(owner_id: current_user.id) if params[:assigned_to_me] == '1'

    sticky_scope = sticky_scope.with_due_date_for_calendar(@first_sunday, @last_saturday)

    @stickies = sticky_scope
  end

  def index
    current_user.update_column :stickies_per_page, params[:stickies_per_page].to_i if params[:stickies_per_page].to_i >= 10 and params[:stickies_per_page].to_i <= 200
    current_user.update_sticky_filters!(params.reject{|k,v| ['stickies_per_page', 'action', 'controller', '_', 'utf8', 'update_filters'].include?(k)}) if params[:update_filters] == '1'

    sticky_scope = (params[:editable_only] == '1') ? current_user.all_stickies : current_user.all_viewable_stickies
    sticky_scope = sticky_scope.with_owner(params[:owner_id] == 'me' ? current_user.id : params[:owner_id]) unless params[:owner_id].blank?

    sticky_scope = sticky_scope.with_owner(current_user.id) if params[:assigned_to_me] == '1'

    @start_date = parse_date(params[:due_date_start_date])
    @end_date = parse_date(params[:due_date_end_date])

    sticky_scope = sticky_scope.due_date_before(@end_date) unless @end_date.blank?
    sticky_scope = sticky_scope.due_date_after(@start_date) unless @start_date.blank?

    sticky_scope = sticky_scope.where(project_id: params[:project_id]) unless params[:project_id].blank?
    sticky_scope = sticky_scope.where("stickies.owner_id IS NOT NULL") if params[:unassigned].to_s != '1'

    unless params[:tag_names].blank?
      if params[:tag_filter] == 'any'
        sticky_scope = sticky_scope.with_tag(Tag.current.where(name: params[:tag_names]).pluck(:id))
      elsif params[:tag_filter] == 'all'
        params[:tag_names].each_with_index do |tag_name, index|
          sticky_scope = sticky_scope.with_tag(Tag.current.where(name: tag_name).pluck(:id))
          # No point in adding more conditions if it's already returning nothing
          # TODO: Also currently unstable adding this condition over 15 times
          break if sticky_scope.count == 0 or index == 14
        end
        # params[:tag_names].each do |tag_name|
        #   sticky_scope = sticky_scope.with_tag_name(tag_name)
        # end
      end
    end

    @search_terms = params[:search].to_s.gsub(/[^0-9a-zA-Z]/, ' ').split(' ')
    @search_terms.each{|search_term| sticky_scope = sticky_scope.search(search_term) }

    sticky_scope = sticky_scope.with_tag(params[:tag_ids].split(',')) unless params[:tag_ids].blank?
    sticky_scope = sticky_scope.with_board(params[:board_id]) unless params[:board_id].blank? or params[:board_id] == 'all'

    @order = ''

    if params[:scope].blank?
      sticky_scope = sticky_scope.where(completed: (params[:status] || []).collect{|v| (v.to_s == 'completed')})
      @order = scrub_order(Sticky, params[:order], 'completed, due_date, end_date DESC, start_date DESC')
    else
      params[:scope] = (['completed', 'past_due', 'upcoming'].include?(params[:scope]) ? params[:scope] : 'past_due')
      case params[:scope] when 'completed'
        sticky_scope = sticky_scope.where(completed: true)
        @order = (params[:scope_direction] == 'reverse' ? "stickies.due_date" : "stickies.due_date DESC")
      when 'past_due'
        sticky_scope = sticky_scope.where(completed: false).due_date_before_or_blank(Date.today)
        @order = (params[:scope_direction] == 'reverse' ? "stickies.due_date" : "stickies.due_date DESC")
      when 'upcoming'
        sticky_scope = sticky_scope.where(completed: false).due_date_after_or_blank(Date.today)
        @order = (params[:scope_direction] == 'reverse' ? "(stickies.due_date IS NULL) DESC, stickies.due_date DESC" : "(stickies.due_date IS NULL) ASC, stickies.due_date ASC")
      end
    end

    sticky_scope = sticky_scope.order(@order)

    @count = sticky_scope.count

    if params[:format] == 'csv'
      @csv_string = CSV.generate do |csv|
        csv << ["Name", "Due Date", "Description", "Status", "Assigned To", "Tags", "Project", "Creator", "Board"]
        sticky_scope.each do |sticky|
          csv << [sticky.name,
                  sticky.due_date.blank? ? '' : sticky.due_date.strftime("%m-%d-%Y"),
                  sticky.description,
                  sticky.completed? ? 'completed' : '',
                  sticky.owner ? sticky.owner.name : '',
                  sticky.tags.collect{|t| t.name}.join('; '),
                  sticky.project.name,
                  sticky.user.name,
                  sticky.board ? sticky.board.name : '']
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

    respond_to do |format|
      format.html
      format.js
      format.json { render json: sticky_scope.page(params[:page]).limit(50) }
    end
  end

  def show
    @sticky = current_user.all_viewable_stickies.find_by_id(params[:id])
    respond_to do |format|
      if @sticky
        format.html # show.html.erb
        format.js
        format.json { render json: @sticky }
      else
        format.html { redirect_to root_path }
        format.js { render nothing: true }
        format.json { head :no_content }
      end
    end
  end

  def popup
    @sticky = current_user.all_viewable_stickies.find_by_id(params[:id])
    render nothing: true unless @sticky
  end

  def new
    @sticky = current_user.stickies.new(post_params)
    @sticky.project = current_user.all_projects.first if not @sticky.project and current_user.all_projects.size == 1
    @project_id = @sticky.project_id
    respond_to do |format|
      format.html
      format.js { render 'edit' }
    end
  end

  def edit
    respond_to do |format|
      if @sticky = current_user.all_stickies.find_by_id(params[:id])
        @project_id = @sticky.project_id
        format.html
        format.js
      else
        if @sticky = current_user.all_viewable_stickies.find_by_id(params[:id])
          format.html { redirect_to @sticky }
          format.js { render 'show' }
        else
          format.html { redirect_to root_path }
          format.js { render nothing: true }
        end
      end
    end
  end

  def create
    @sticky = current_user.stickies.new(post_params)

    respond_to do |format|
      if @sticky.save
        flash[:notice] = 'Sticky was successfully created.'
        if params[:from_calendar] == '1'
          # redirect_to calendar_stickies_path(selected_date: @sticky.due_date.blank? ? '' : @sticky.due_date.strftime('%m/%d/%Y'))
          # Will render create.js instead
          format.js { render 'create' }
        else
          format.js { render 'update' } # Update handles board reloading
          format.html { redirect_to @sticky }
        end
        format.json { render json: @sticky, status: :created, location: @sticky }
      else
        @project_id = @sticky.project_id
        format.html { render "new" }
        format.js { render "new" }
        format.json { render json: @sticky.errors, status: :unprocessable_entity }
      end
    end
  end

  def move
    params[:due_date] = parse_date(params[:due_date])

    @sticky = current_user.all_stickies.find_by_id(params[:id])

    params[:due_date] = Time.parse(params[:due_date].strftime("%Y-%m-%d ") + @sticky.due_at_string) rescue ''

    if @sticky and not params[:due_date].blank?
      original_due_date = @sticky.due_date
      @sticky.update_attributes due_date: params[:due_date]

      @sticky.shift_group(((@sticky.due_date - original_due_date) / 1.day).round, params[:shift]) if not original_due_date.blank? and not @sticky.due_date.blank?
    else
      @sticky = current_user.all_viewable_stickies.find_by_id(params[:id])
    end

    if @sticky
      if @group = @sticky.group
        render 'groups/create'
      else
        render 'create'
      end
    else
      render nothing: true
    end
  end

  def move_to_board
    @sticky = current_user.all_stickies.find_by_id(params[:id])
    @board = current_user.all_boards.find_by_id(params[:board_id])
    @original_board = @sticky.board if @sticky

    if @sticky and @board and @sticky.board != @board
      @sticky.update_attributes(board_id: @board.id)
    elsif @sticky and params[:board_id].to_s == '0' and @sticky.board != nil
      @sticky.update_attributes(board_id: nil)
    else
      render nothing: true
    end
  end

  def complete
    @sticky = current_user.all_stickies.find_by_id(params[:id])

    if @sticky
      @sticky.update_attributes completed: (params[:undo] != 'true')
    else
      render nothing: true
    end
  end

  def complete_multiple
    @stickies = current_user.all_stickies.where(id: params[:sticky_ids].to_s.split(','))

    if @stickies
      @stickies.each{|s| s.update_attributes(completed: (params[:undo] != 'true'))}
    else
      render nothing: true
    end
  end

  def update
    @sticky = current_user.all_stickies.find_by_id(params[:id])

    respond_to do |format|
      if @sticky
        original_due_date = @sticky.due_date
        if @sticky.update_attributes(post_params)
          flash[:notice] = 'Sticky was successfully updated.'

          @sticky.shift_group(((@sticky.due_date - original_due_date) / 1.day).round, params[:shift]) if not original_due_date.blank? and not @sticky.due_date.blank?

          if params[:from_calendar] == '1'
            format.html { redirect_to calendar_stickies_path(selected_date: @sticky.due_date.blank? ? '' : @sticky.due_date.strftime('%m/%d/%Y')) }
          elsif params[:from] == 'index'
            format.html { redirect_to stickies_path }
          elsif params[:from] == 'project'
            format.html { redirect_to project_path(@sticky.project, board_id: @sticky.board_id) }
          else
            format.html { redirect_to @sticky }
          end
          format.js
          format.json { render json: @sticky, status: :created, location: @sticky }
        else
          @project_id = @sticky.project_id
          format.html { render action: "edit" }
          format.js { render 'edit' }
          format.json { render json: @sticky.errors, status: :unprocessable_entity }
        end
      else
        format.html { redirect_to root_path }
        format.js { render nothing: true }
        format.json { head :no_content }
      end
    end
  end

  def destroy
    @sticky = current_user.all_stickies.find_by_id(params[:id])

    respond_to do |format|
      if @sticky
        if @sticky.group and params[:discard] == 'following'
          @sticky.group.stickies.where('due_date >= ?', @sticky.due_date).destroy_all
        elsif @sticky.group and params[:discard] == 'all'
          @sticky.group.destroy
        else # 'single'
          @sticky.destroy
        end
        format.html do
          flash[:notice] = 'Sticky was successfully deleted.'
          if params[:from_calendar] == '1'
            redirect_to calendar_stickies_path(selected_date: @sticky.due_date.blank? ? '' : @sticky.due_date.strftime('%m/%d/%Y'))
          else
            redirect_to stickies_path
          end
        end
        format.js  { render 'destroy' }
      else
        format.html { redirect_to root_path }
        format.js { render nothing: true }
      end
    end
  end

  def destroy_multiple
    @stickies = current_user.all_stickies.where(id: params[:sticky_ids].to_s.split(','))

    respond_to do |format|
      if @stickies.size > 0
        @stickies.each{ |s| s.destroy }
        format.js
      else
        format.js { render nothing: true }
      end
    end
  end

  private

  def post_params
    params[:sticky] ||= {}
    params[:sticky][:tag_ids] ||= []

    params[:sticky][:due_date] = parse_date(params[:sticky][:due_date])

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

    unless params[:sticky][:project_id].blank?
      project = current_user.all_projects.find_by_id(params[:sticky][:project_id])
      params[:sticky][:project_id] = project ? project.id : nil
    end

    if project and params[:create_new_board] == '1'
      if params[:sticky_board_name].to_s.strip.blank?
        params[:sticky][:board_id] = nil
      else
        @board = project.boards.find_or_create_by_name(params[:sticky_board_name].to_s.strip, { user_id: current_user.id })
        params[:sticky][:board_id] = @board.id
      end
    end

    params[:sticky].slice(
      :description, :project_id, :owner_id, :board_id, :due_date, :completed, :duration, :duration_units, :all_day, :tag_ids
    )
  end
end
