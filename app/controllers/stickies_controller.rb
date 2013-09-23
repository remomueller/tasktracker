class StickiesController < ApplicationController
  before_action :authenticate_user!
  before_action :api_authentication!, only: [ :index, :show, :create, :update ]
  before_action :set_viewable_sticky, only: [ :show ]
  before_action :set_editable_sticky, only: [ :edit, :move, :move_to_board, :complete, :completebs3, :update, :destroy ]
  before_action :redirect_without_sticky, only: [ :show, :update, :completebs3, :destroy ]
  before_action :set_filtered_sticky_scope, only: [ :day, :week, :month, :tasks ]

  def day
    @beginning = @anchor_date.wday == 0 ? @anchor_date : @anchor_date.beginning_of_week - 1.day
  end

  def week
    week_padding = 12
    @beginning_of_anchor_week = @anchor_date.wday == 0 ? @anchor_date : @anchor_date.beginning_of_week - 1.day
    @beginning = @beginning_of_anchor_week - week_padding.weeks
    @ending = @beginning + (2 * week_padding + 1).weeks - 1.day
    completed_dates = @stickies.with_due_date_for_calendar(@beginning, @beginning + 6.months - 1.day).where( completed: true ).pluck( :due_date )
    incomplete_dates = @stickies.with_due_date_for_calendar(@beginning, @beginning + 6.months - 1.day).where( completed: false ).pluck( :due_date )
    @date_count_hash = {}
    ['S','M','T','W','R','F','S'].each_with_index do |day, day_index|
      date = @beginning
      while date <= @ending
        current_date = (date + day_index.days)
        completed = completed_dates.select{|d| current_date == d.to_date }.count
        incomplete = incomplete_dates.select{|d| current_date == d.to_date }.count
        @date_count_hash[current_date.strftime("%Y%m%d")] = { completed: completed, incomplete: incomplete }
        date = date + 1.week
      end
    end
    # @max_completed_count = @date_count_hash.collect{|k,v| v[:completed]}.max || 0
    @max_incomplete_count = @date_count_hash.collect{|k,v| v[:incomplete]}.max || 0
  end

  def month
    @start_date = @anchor_date.beginning_of_month
    @end_date = @anchor_date.end_of_month

    @first_sunday = @start_date - @start_date.wday.day
    @last_saturday = @end_date + (6 - @end_date.wday).day

    @stickies = @stickies.with_due_date_for_calendar(@first_sunday, @last_saturday)
  end

  # GET /tasks
  def tasks
    @tasks = @stickies.search(params[:search]).page(params[:page]).per(50)
    respond_to do |format|
      format.html { render 'tasks/index' }
      format.js { render 'tasks/index' }
    end
  end

  # GET /stickies
  # GET /stickies.json
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
        @order = (params[:scope_direction] == 'reverse' ? "stickies.due_date NULLS FIRST" : "stickies.due_date DESC NULLS LAST")
      when 'past_due'
        sticky_scope = sticky_scope.where(completed: false).due_date_before_or_blank(Date.today)
        @order = (params[:scope_direction] == 'reverse' ? "stickies.due_date NULLS FIRST" : "stickies.due_date DESC NULLS LAST")
      when 'upcoming'
        sticky_scope = sticky_scope.where(completed: false).due_date_after_or_blank(Date.today)
        @order = (params[:scope_direction] == 'reverse' ? "(stickies.due_date IS NULL) DESC, stickies.due_date DESC" : "(stickies.due_date IS NULL) ASC, stickies.due_date ASC")
      end
    end

    sticky_scope = sticky_scope.search(params[:search]).order(@order)

    if params[:format] == 'csv'
      @csv_string = CSV.generate do |csv|
        csv << ["Name", "Due Date", "Description", "Status", "Assigned To", "Tags", "Project", "Creator", "Board", "Duration", "Duration Units"]
        sticky_scope.each do |sticky|
          csv << [sticky.name,
                  sticky.due_date.blank? ? '' : sticky.due_date.strftime("%m-%d-%Y"),
                  sticky.description,
                  sticky.completed? ? 'completed' : '',
                  sticky.owner ? sticky.owner.name : '',
                  sticky.tags.collect{|t| t.name}.join('; '),
                  sticky.project.name,
                  sticky.user.name,
                  sticky.board ? sticky.board.name : '',
                  sticky.duration,
                  sticky.duration_units]
        end
      end
      send_data @csv_string, type: 'text/csv; charset=iso-8859-1; header=present',
                            disposition: "attachment; filename=\"Stickies #{Time.now.strftime("%Y.%m.%d %Ih%M %p")}.csv\""
      return
    end

    @stickies = sticky_scope.page(params[:page]).per((params[:use_template] == 'redesign' or params[:format] == 'json') ? 50 : current_user.stickies_per_page)
  end

  # GET /stickies/1
  # GET /stickies/1.json
  def show
  end

  # GET /stickies/new
  def new
    @sticky = current_user.stickies.new(sticky_params)
    @sticky.project = current_user.all_projects.first if not @sticky.project and current_user.all_projects.size == 1
    respond_to do |format|
      format.html
      format.js
    end
  end

  # GET /stickies/1/edit
  def edit
    respond_to do |format|
      if @sticky
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

  # POST /stickies
  # POST /stickies.json
  def create
    @sticky = current_user.stickies.new(sticky_params)

    respond_to do |format|
      if @sticky.save
        @sticky.send_email_if_recently_completed(current_user)
        format.html { redirect_to @sticky, notice: 'Sticky was successfully created.' }
        format.js
        format.json { render action: 'show', status: :created, location: @sticky }
      else
        @project_id = @sticky.project_id
        format.html { render 'new' }
        format.js { render 'new' }
        format.json { render json: @sticky.errors, status: :unprocessable_entity }
      end
    end
  end

  def move
    params[:due_date] = parse_date(params[:due_date])
    params[:due_date] = Time.zone.parse(params[:due_date].strftime("%Y-%m-%d ") + @sticky.due_at_string) rescue ''

    if @sticky and not params[:due_date].blank?
      original_due_date = @sticky.due_date
      @sticky.update_attributes due_date: params[:due_date]

      @sticky.shift_group(((@sticky.due_date - original_due_date) / 1.day).round, params[:shift]) if not original_due_date.blank? and not @sticky.due_date.blank?
    else
      @sticky = current_user.all_viewable_stickies.find_by_id(params[:id])
    end

    if @sticky
      if @group = @sticky.group
        render 'groups/update'
      else
        render 'update'
      end
    else
      render nothing: true
    end
  end

  def move_to_board
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

  def completebs3
    @sticky.update( completed: params[:completed] )
    @sticky.send_email_if_recently_completed(current_user)
  end

  # This is always from calendar, the project one always uses complete_multiple...(todo refactor)
  def complete
    params[:hide_show] = '1'

    if @sticky
      @sticky.update_attributes completed: (params[:undo] != 'true')
      @sticky.send_email_if_recently_completed(current_user)
      if ['month', 'week', 'day', 'checkbox', 'move'].include?(params[:from]) or params[:from_index] == '1'
        render 'update'
      else
        @stickies = Sticky.current.where(id: @sticky.id)
        render 'complete_multiple'
      end
    else
      render nothing: true
    end
  end

  def complete_multiple
    @stickies = current_user.all_stickies.where(id: params[:sticky_ids].to_s.split(','))

    if @stickies and @stickies.size > 0
      @stickies.each{|s| s.update_attributes(completed: (params[:undo] != 'true'))}
      if params[:undo] != 'true'
        if @stickies.size == 1
          @stickies.first.send_email_if_recently_completed(current_user)
        else
          Sticky.send_stickies_completion_email(@stickies, current_user)
        end
      end
    else
      render nothing: true
    end
  end

  # PUT /stickies/1
  # PUT /stickies/1.json
  def update
    original_due_date = @sticky.due_date

    respond_to do |format|
      if @sticky.update(sticky_params)
        @sticky.send_email_if_recently_completed(current_user)

        @sticky.shift_group(((@sticky.due_date - original_due_date) / 1.day).round, params[:shift]) if not original_due_date.blank? and not @sticky.due_date.blank?

        format.html { redirect_to @sticky, notice: 'Sticky was successfully updated.' }
        format.js
        format.json { render action: 'show', location: @sticky }
      else
        @project_id = @sticky.project_id
        format.html { render action: 'edit' }
        format.js { render 'edit' }
        format.json { render json: @sticky.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stickies/1
  # DELETE /stickies/1.json
  def destroy
    if @sticky.group and params[:discard] == 'following'
      @sticky.group.stickies.where('due_date >= ?', @sticky.due_date).destroy_all
    elsif @sticky.group and params[:discard] == 'all'
      @sticky.group.destroy
    else # 'single'
      @sticky.destroy
    end

    respond_to do |format|
      format.html { redirect_to month_path( date: @sticky.due_date.blank? ? '' : @sticky.due_date.strftime('%Y%m%d') ), notice: 'Sticky was successfully deleted.' }
      format.js
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

    def set_viewable_sticky
      @sticky = current_user.all_viewable_stickies.find_by_id(params[:id])
    end

    def set_editable_sticky
      @sticky = current_user.all_stickies.find_by_id(params[:id])
    end

    def redirect_without_sticky
      empty_response_or_root_path(stickies_path) unless @sticky
    end

    def sticky_params
      params[:sticky] ||= {}

      params[:sticky][:due_date] = parse_date(params[:sticky][:due_date]) unless params[:sticky][:due_date].blank?

      params[:sticky][:all_day] = begin
        unless params[:sticky][:due_at_string].blank?
          t = Time.parse(params[:sticky][:due_at_string])
          params[:sticky][:due_date] = Time.zone.parse(params[:sticky][:due_date].strftime("%Y-%m-%d ") + params[:sticky][:due_at_string])
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
          @board = project.boards.where( name: params[:sticky_board_name].to_s.strip ).first_or_create( user_id: current_user.id )
          params[:sticky][:board_id] = @board.id
        end
      end

      params[:sticky][:repeat] = ( Sticky::REPEAT.flatten.uniq.include?(params[:sticky][:repeat]) ? params[:sticky][:repeat] : 'none' ) unless params[:sticky][:repeat].blank?
      params[:sticky][:repeat_amount] = 1 if params[:sticky][:repeat] == 'none'

      params.require(:sticky).permit(
        :description, :project_id, :owner_id, :board_id, :due_date, :completed, :duration, :duration_units, :all_day, { :tag_ids => [] }, :repeat, :repeat_amount
      )
    end

    def set_filtered_sticky_scope
      @anchor_date = (Date.parse(params[:date]) rescue Date.today)

      sticky_scope = current_user.all_viewable_stickies
      sticky_scope = sticky_scope.with_tag(current_user.all_viewable_tags.where(name: params[:tags].to_s.split(',')).pluck(:id)) unless params[:tags].blank?
      sticky_scope = sticky_scope.where(owner_id: User.where( deleted: false ).with_name(params[:owners].to_s.split(',')).pluck(:id)) unless params[:owners].blank?
      sticky_scope = sticky_scope.where(project_id: current_user.all_viewable_projects.where(id: params[:project_ids].to_s.split(',')).pluck(:id)) unless params[:project_ids].blank?
      @stickies = sticky_scope
    end

end
