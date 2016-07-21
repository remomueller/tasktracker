# frozen_string_literal: true

# Defines a group of tasks that were created together.
class GroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_viewable_project, only: [:index]
  before_action :find_editable_project_or_first_project, only: [:new, :create]
  before_action :set_viewable_group, only: [:show]
  before_action :set_editable_group, only: [:edit, :update, :destroy]
  before_action :redirect_without_group, only: [:show, :edit, :update, :destroy]

  # GET /groups
  def index
    @order = scrub_order(Group, params[:order], 'groups.id DESC')
    @groups = current_user.all_viewable_groups.search(params[:search]).filter(params)
                          .order(@order).page(params[:page]).per(40)
  end

  # GET /groups/1
  def show
  end

  # GET /groups/new
  def new
    if @project
      @group = @project.groups.new(group_params)
      @group.template = @project.templates.first if @project.templates.size == 1
    end

    respond_to do |format|
      format.js
      format.html { redirect_to groups_path }
    end
  end

  # GET /groups/1/edit
  def edit
  end

  # POST /groups
  # POST /groups.js
  def create
    g_params = group_params

    @template = @project.templates.find_by_id(params[:group][:template_id]) if @project && params[:group]

    if @template
      @group = @template.generate_stickies!(current_user, g_params[:board_id], g_params[:initial_due_date], g_params[:description])
      respond_to do |format|
        format.html { redirect_to @group, notice: @group.stickies.size.to_s + ' ' + ((@group.stickies.size == 1) ? 'sticky' : 'stickies') + " successfully created and added to #{(@board ? @board.name : 'Holding Pen')}." }
        format.js { render :create }
      end
    else
      @group = @project.groups.new(g_params) if @project
      respond_to do |format|
        format.html { redirect_to groups_path }
        format.js { render :new }
      end
    end
  end

  # PATCH /groups/1
  def update
    if @group.update(group_params)
      redirect_to @group, notice: 'Group was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /groups/1
  def destroy
    @group.destroy
    redirect_to groups_path
  end

  private

  def set_viewable_group
    @group = current_user.all_viewable_groups.find_by_id(params[:id])
  end

  def set_editable_group
    @group = current_user.all_groups.find_by_id(params[:id])
  end

  def redirect_without_group
    empty_response_or_root_path(groups_path) unless @group
  end

  def group_params
    params[:group] ||= { blank: '1' } # {}

    if @project && params[:create_new_board] == '1'
      if params[:group_board_name].to_s.strip.blank?
        params[:group][:board_id] = nil
      else
        @board = @project.boards.where(name: params[:group_board_name].to_s.strip).first_or_create(user_id: current_user.id)
        params[:group][:board_id] = @board.id
      end
    elsif @project
      @board = @project.boards.find_by_id(params[:group][:board_id])
    end

    params[:group][:board_id] = (@board ? @board.id : nil)

    params[:group][:initial_due_date] = parse_date(params[:group][:initial_due_date], Time.zone.today)

    params.require(:group).permit(
      :description, :board_id, :template_id, :initial_due_date
    )
  end
end
