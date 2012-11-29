class BoardsController < ApplicationController
  before_filter :authenticate_user!

  def index
    current_user.update_column :boards_per_page, params[:boards_per_page].to_i if params[:boards_per_page].to_i >= 10 and params[:boards_per_page].to_i <= 200
    board_scope = current_user.all_viewable_boards
    @search_terms = params[:search].to_s.gsub(/[^0-9a-zA-Z]/, ' ').split(' ')
    @search_terms.each{|search_term| board_scope = board_scope.search(search_term) }

    board_scope = board_scope.with_project(@project.id, current_user.id) if @project = current_user.all_viewable_projects.find_by_id(params[:project_id])

    @order = scrub_order(Board, params[:order], 'boards.name')
    board_scope = board_scope.order(@order)

    @count = board_scope.count
    @boards = board_scope.page(params[:page]).per(current_user.boards_per_page)

    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json { render json: @boards }
    end
  end

  def show
    @board = current_user.all_viewable_boards.find_by_id(params[:id])
    redirect_to root_path unless @board
  end

  def new
    @board = current_user.boards.new(post_params)
  end

  def edit
    @board = current_user.all_boards.find_by_id(params[:id])
    redirect_to root_path unless @board
  end

  def create
    @board = current_user.boards.new(post_params)

    if @board.save
      redirect_to(@board, notice: 'Board was successfully created.')
    else
      render action: "new"
    end
  end

  def update
    @board = current_user.all_boards.find_by_id(params[:id])

    if @board
      if @board.update_attributes(post_params)
        redirect_to(@board, notice: 'Board was successfully updated.')
      else
        render action: "edit"
      end
    else
      redirect_to root_path
    end
  end

  def destroy
    @board = current_user.all_boards.find_by_id(params[:id])
    @board.destroy if @board

    respond_to do |format|
      format.html { redirect_to boards_path(project_id: @board ? @board.project_id : nil) }
      format.json { head :no_content }
    end
  end

  def post_params
    params[:board] ||= {}

    [:start_date, :end_date].each do |date|
      params[:board][date] = parse_date(params[:board][date])
    end

    unless params[:board][:project_id].blank?
      project = current_user.all_projects.find_by_id(params[:board][:project_id])
      params[:board][:project_id] = project ? project.id : nil
    end

    params[:board].slice(
      :name, :description, :start_date, :end_date, :project_id
    )
  end
end
