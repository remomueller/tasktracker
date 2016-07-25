# frozen_string_literal: true

# Allows tasks to be created and viewed.
class StickiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_viewable_sticky, only: [:show]
  before_action :find_editable_project_or_first_project, only: [:new, :create, :edit, :update]
  before_action :set_editable_sticky, only: [:edit, :move, :move_to_board, :complete, :update, :destroy]
  before_action :redirect_without_sticky, only: [:show, :update, :destroy]
  before_action :set_filtered_sticky_scope, only: [:day, :week, :month, :tasks]

  def day
    @beginning = @anchor_date.wday == 0 ? @anchor_date : @anchor_date.beginning_of_week - 1.day
  end

  def week
    flash.delete(:notice)
    week_padding = 12
    @beginning_of_anchor_week = @anchor_date.wday == 0 ? @anchor_date : @anchor_date.beginning_of_week - 1.day
    @beginning = @beginning_of_anchor_week - week_padding.weeks
    @ending = @beginning + (2 * week_padding + 1).weeks - 1.day
    completed_dates = @stickies.with_due_date_for_calendar(@beginning, @beginning + 6.months - 1.day).where(completed: true).pluck(:due_date)
    incomplete_dates = @stickies.with_due_date_for_calendar(@beginning, @beginning + 6.months - 1.day).where(completed: false).pluck(:due_date)
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
    flash.delete(:notice)
    @start_date = @anchor_date.beginning_of_month
    @end_date = @anchor_date.end_of_month

    @first_sunday = @start_date - @start_date.wday.day
    @last_saturday = @end_date + (6 - @end_date.wday).day

    @stickies = @stickies.with_due_date_for_calendar(@first_sunday, @last_saturday)
  end

  # GET /tasks
  def tasks
    @stickies = @stickies.search(params[:search])

    if params[:format] == 'csv'
      generate_csv(@stickies)
      return
    end

    @tasks = @stickies.page(params[:page]).per( 40 )
    render 'tasks/index'
  end

  # GET /stickies
  # GET /stickies.js
  def index
    sticky_scope = current_user.all_stickies
    sticky_scope = sticky_scope.with_owner(current_user.id) if params[:assigned_to_me] == '1'
    sticky_scope = sticky_scope.where(project_id: params[:project_id]) unless params[:project_id].blank?
    sticky_scope = sticky_scope.where.not(owner_id: nil) if params[:unassigned].to_s != '1'
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

    sticky_scope = sticky_scope.search(params[:search]).reorder(@order)
    @stickies = sticky_scope.page(params[:page]).per(40)
    respond_to do |format|
      format.html { redirect_to tasks_path }
      format.js
    end
  end

  # GET /stickies/1
  def show
  end

  # GET /stickies/new
  def new
    if @project
      params[:sticky] ||= {}
      params[:sticky][:due_date] = params[:due_date]
      @sticky = @project.stickies.new(sticky_params)
    end
    respond_to do |format|
      format.html
      format.js
    end
  end

  # GET /stickies/1/edit
  def edit
    respond_to do |format|
      if @sticky
        @project = @sticky.project
        format.html
        format.js
      else
        if @sticky = current_user.all_viewable_stickies.find_by_id(params[:id])
          format.html { redirect_to @sticky }
          format.js { render :show }
        else
          format.html { redirect_to root_path }
          format.js { head :ok }
        end
      end
    end
  end

  # POST /stickies
  # POST /stickies.js
  def create
    @sticky = @project.stickies.where(user_id: current_user.id).new(sticky_params)

    respond_to do |format|
      if @sticky.save
        @sticky.send_email_in_background
        @sticky.send_email_if_recently_completed(current_user)
        format.html { redirect_to @sticky, notice: 'Task was successfully created.' }
        format.js
      else
        @project = @sticky.project
        format.html { render :new }
        format.js { render :new }
      end
    end
  end

  def move
    params[:due_date] = parse_date(params[:due_date])
    @all_dates = []

    if @sticky && params[:due_date].present?
      @from_date = @sticky.due_date
      @sticky.update due_date: params[:due_date]
      @to_date = @sticky.due_date
      @all_dates += [@from_date, @to_date]
      @all_dates += @sticky.shift_group((@to_date - @from_date).round, params[:shift]) if @from_date.present? && @to_date.present?
      @all_dates.compact.uniq!
    else
      @sticky = current_user.all_viewable_stickies.find_by_id(params[:id])
    end

    if @sticky
      @group = @sticky.group
      if @group
        render 'groups/update'
      else
        render 'update'
      end
    else
      head :ok
    end
  end

  def move_to_board
    @board = current_user.all_boards.find_by_id(params[:board_id])
    @original_board = @sticky.board if @sticky

    if @sticky && @board && @sticky.board != @board
      @sticky.update(board_id: @board.id)
    elsif @sticky && params[:board_id].to_s == '0' && !@sticky.board.nil?
      @sticky.update(board_id: nil)
    else
      head :ok
    end
  end

  # TODO: Remove all references
  def complete
    if @sticky
      @sticky.update completed: (params[:undo] != 'true')
      @sticky.send_email_if_recently_completed(current_user)
      @all_dates = [@sticky.due_date].compact
      render :update
    else
      head :ok
    end
  end

  # PATCH /stickies/1
  # PATCH /stickies/1.js
  def update
    @from_date = @sticky.due_date

    respond_to do |format|
      if @sticky.update(sticky_params)
        @to_date = @sticky.due_date
        @all_dates = [@from_date, @to_date]
        @sticky.send_email_if_recently_completed(current_user)
        @all_dates += @sticky.shift_group((@to_date - @from_date).round, params[:shift]) if @from_date.present? && @to_date.present?
        format.html { redirect_to @sticky, notice: 'Task was successfully updated.' }
        format.js
      else
        format.html { render :edit }
        format.js { render :edit }
      end
    end
  end

  # DELETE /stickies/1
  # DELETE /stickies/1.js
  def destroy
    if @sticky.group and params[:discard] == 'following'
      @sticky.group.stickies.where('due_date >= ?', @sticky.due_date).destroy_all
    elsif @sticky.group and params[:discard] == 'all'
      @sticky.group.destroy
    else # 'single'
      @sticky.destroy
    end

    respond_to do |format|
      format.html { redirect_to month_path( date: @sticky.due_date.blank? ? '' : @sticky.due_date.strftime('%Y%m%d') ), notice: 'Task was successfully deleted.' }
      format.js
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
    params[:sticky] ||= { blank: '1' }

    params[:sticky][:due_date] = parse_date(params[:sticky][:due_date]) unless params[:sticky][:due_date].blank?

    if @project && params[:create_new_board] == '1'
      if params[:sticky_board_name].to_s.strip.blank?
        params[:sticky][:board_id] = nil
      else
        @board = @project.boards.where(name: params[:sticky_board_name].to_s.strip).first_or_create(user_id: current_user.id)
        params[:sticky][:board_id] = @board.id
      end
    end

    params[:sticky][:repeat] = (Sticky::REPEAT.flatten.uniq.include?(params[:sticky][:repeat]) ? params[:sticky][:repeat] : 'none') unless params[:sticky][:repeat].blank?
    params[:sticky][:repeat_amount] = 1 if params[:sticky][:repeat] == 'none'

    params.require(:sticky).permit(
      :description, :owner_id, :board_id, :due_date, :due_time, :completed, :duration, :duration_units, :all_day, { :tag_ids => [] }, :repeat, :repeat_amount
    )
  end

  def set_filtered_sticky_scope
    @anchor_date = (Date.parse(params[:date]) rescue Date.today)

    sticky_scope = current_user.all_viewable_stickies
    sticky_scope = sticky_scope.with_tag(current_user.all_viewable_tags.where(name: params[:tags].to_s.split(',')).select(:id)) unless params[:tags].blank?
    unless params[:owners].blank?
      owners = User.current.with_name(params[:owners].to_s.split(','))
      owner_project_ids = owners.collect { |o| o.all_projects.pluck(:id) }.flatten.uniq
      sticky_scope = sticky_scope.where(owner_id: owners.pluck(:id) + [nil], project_id: owner_project_ids)
    end
    sticky_scope = sticky_scope.where( completed: params[:completed].to_s.split(',') ) unless params[:completed].blank?
    sticky_scope = sticky_scope.where(project_id: current_user.all_viewable_projects.where(id: params[:project_ids].to_s.split(',')).select(:id)) unless params[:project_ids].blank?
    @stickies = sticky_scope
  end

  def generate_csv(task_scope)
    @csv_string = CSV.generate do |csv|
      csv << ['Name', 'Due Date', 'Description', 'Completed', 'Assigned To', 'Tags', 'Project', 'Creator', 'Board', 'Due Time', 'Duration', 'Duration Units']
      task_scope.each do |sticky|
        csv << [sticky.name,
                sticky.due_date.blank? ? '' : sticky.due_date.strftime("%m-%d-%Y"),
                sticky.description,
                sticky.completed? ? 'X' : '',
                sticky.owner ? sticky.owner.name : '',
                sticky.tags.collect{|t| t.name}.join('; '),
                sticky.project.name,
                sticky.user.name,
                sticky.board ? sticky.board.name : '',
                sticky.due_time,
                sticky.duration,
                sticky.duration_units]
      end
    end
    send_data @csv_string, type: 'text/csv; charset=iso-8859-1; header=present',
                           disposition: "attachment; filename=\"#{current_user.last_name.gsub(/[^a-zA-Z0-9_]/, '_')}_#{Time.zone.today.strftime('%Y%m%d')}.csv\""
  end
end
