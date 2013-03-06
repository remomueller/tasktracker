class BoardsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_viewable_project, only: [ :index ]
  before_action :set_editable_project, only: [ :add_stickies ]
  before_action :redirect_without_project, only: [ :add_stickies ]
  before_action :set_viewable_board, only: [ :show ]
  before_action :set_editable_board, only: [ :edit, :update, :destroy, :archive ]
  before_action :redirect_without_board, only: [ :show, :edit, :update, :destroy, :archive ]

  def archive
    @project = current_user.all_projects.find_by_id(@board.project_id)

    if @project
      @board.update(archived: params[:archived])
    else
      render nothing: true
    end
  end

  def add_stickies
    @board = current_user.all_boards.find_by_id(params[:board_id])
    @stickies = @project.stickies.where(id: params[:sticky_ids].split(','))

    if (@board or params[:board_id].to_s == '0') and @stickies.size > 0
      board_id = (@board ? @board.id : nil)
      @board_ids = (@stickies.pluck(:board_id) + [board_id]).uniq
      @stickies.each{|s| s.update(board_id: board_id)}
    else
      render nothing: true
    end
  end

  # GET /boards
  # GET /boards.json
  def index
    current_user.update_column :boards_per_page, params[:boards_per_page].to_i if params[:boards_per_page].to_i >= 10 and params[:boards_per_page].to_i <= 200
    @order = scrub_order(Board, params[:order], 'boards.name')
    @boards = current_user.all_viewable_boards.search(params[:search]).filter(params).order(@order).page(params[:page]).per(current_user.boards_per_page)
  end

  # GET /boards/1
  # GET /boards/1.json
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
  # POST /boards.json
  def create
    @board = current_user.boards.new(board_params)

    respond_to do |format|
      if @board.save
        format.html { redirect_to @board, notice: 'Board was successfully created.' }
        format.json { render action: 'show', status: :created, location: @board }
      else
        format.html { render action: 'new' }
        format.json { render json: @board.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /boards/1
  # PUT /boards/1.json
  def update
    respond_to do |format|
      if @board.update(board_params)
        format.html { redirect_to @board, notice: 'Board was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @board.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /boards/1
  # DELETE /boards/1.json
  def destroy
    @board.destroy

    respond_to do |format|
      format.html { redirect_to boards_path( project_id: @board.project_id ) }
      format.json { head :no_content }
    end
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
      params[:board] ||= { blank: '1' } # {}

      unless params[:board][:project_id].blank?
        project = current_user.all_projects.find_by_id(params[:board][:project_id])
        params[:board][:project_id] = project ? project.id : nil
      end

      params.require(:board).permit(
        :name, :description, :project_id, :archived
      )
    end
end
