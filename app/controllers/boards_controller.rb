# frozen_string_literal: true

# Allows project boards to be created to categorize tasks.
class BoardsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_viewable_project, only: [:index]
  before_action :set_editable_project, only: [:add_stickies]
  before_action :redirect_without_project, only: [:add_stickies]
  before_action :set_viewable_board, only: [:show]
  before_action :set_editable_board, only: [:edit, :update, :destroy, :archive]
  before_action :redirect_without_board, only: [:show, :edit, :update, :destroy, :archive]

  def archive
    @board.update archived: params[:archived]
    @project = @board.project
  end

  def add_stickies
    @board = current_user.all_boards.find_by_id(params[:board_id])
    @stickies = @project.stickies.where(id: params[:sticky_ids].split(','))

    if (@board || params[:board_id].to_s == '0') && @stickies.size > 0
      board_id = (@board ? @board.id : nil)
      @board_ids = (@stickies.pluck(:board_id) + [board_id]).uniq
      @stickies.each{|s| s.update(board_id: board_id)}
    else
      head :ok
    end
  end

  # GET /boards
  def index
    @order = scrub_order(Board, params[:order], 'boards.name')
    @boards = current_user.all_viewable_boards.search(params[:search])
                          .filter(params).order(@order)
                          .page(params[:page]).per(40)
  end

  # GET /boards/1
  def show
  end

  # GET /boards/new
  def new
    @board = current_user.boards.new(board_params)
  end

  # GET /boards/1/edit
  def edit
  end

  # POST /boards
  def create
    @board = current_user.boards.new(board_params)

    if @board.save
      redirect_to @board, notice: 'Board was successfully created.'
    else
      render :new
    end
  end

  # PATCH /boards/1
  def update
    if @board.update(board_params)
      redirect_to @board, notice: 'Board was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /boards/1
  def destroy
    @board.destroy
    redirect_to boards_path(project_id: @board.project_id)
  end

  private

  def set_viewable_board
    @board = current_user.all_viewable_boards.find_by_id(params[:id])
  end

  def set_editable_board
    @board = current_user.all_boards.find_by_id(params[:id])
  end

  def redirect_without_board
    empty_response_or_root_path(boards_path) unless @board
  end

  def board_params
    params[:board] ||= { blank: '1' }

    unless params[:board][:project_id].blank?
      project = current_user.all_projects.find_by_id(params[:board][:project_id])
      params[:board][:project_id] = project ? project.id : nil
    end

    params.require(:board).permit(
      :name, :description, :project_id, :archived
    )
  end
end
