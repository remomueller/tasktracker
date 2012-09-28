class FramesController < ApplicationController
  before_filter :authenticate_user!

  def index
    current_user.update_column :frames_per_page, params[:frames_per_page].to_i if params[:frames_per_page].to_i >= 10 and params[:frames_per_page].to_i <= 200
    frame_scope = current_user.all_viewable_frames
    @search_terms = params[:search].to_s.gsub(/[^0-9a-zA-Z]/, ' ').split(' ')
    @search_terms.each{|search_term| frame_scope = frame_scope.search(search_term) }

    frame_scope = frame_scope.with_project(@project.id, current_user.id) if @project = current_user.all_viewable_projects.find_by_id(params[:project_id])

    @order = scrub_order(Frame, params[:order], 'frames.end_date DESC')
    frame_scope = frame_scope.order(@order)

    @count = frame_scope.count
    @frames = frame_scope.page(params[:page]).per(current_user.frames_per_page)

    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json { render json: @frames }
    end
  end

  def show
    @frame = current_user.all_viewable_frames.find_by_id(params[:id])
    redirect_to root_path unless @frame
  end

  def new
    @frame = current_user.frames.new(post_params)
  end

  def edit
    @frame = current_user.all_frames.find_by_id(params[:id])
    redirect_to root_path unless @frame
  end

  def create
    @frame = current_user.frames.new(post_params)

    if @frame.save
      redirect_to(@frame, notice: 'Frame was successfully created.')
    else
      render action: "new"
    end
  end

  def update
    @frame = current_user.all_frames.find_by_id(params[:id])

    if @frame
      if @frame.update_attributes(post_params)
        redirect_to(@frame, notice: 'Frame was successfully updated.')
      else
        render action: "edit"
      end
    else
      redirect_to root_path
    end
  end

  def destroy
    @frame = current_user.all_frames.find_by_id(params[:id])
    @frame.destroy if @frame

    respond_to do |format|
      format.html { redirect_to frames_path(project_id: @frame ? @frame.project_id : nil) }
      format.json { head :no_content }
    end
  end

  def post_params
    params[:frame] ||= {}

    [:start_date, :end_date].each do |date|
      params[:frame][date] = parse_date(params[:frame][date])
    end

    unless params[:frame][:project_id].blank?
      project = current_user.all_projects.find_by_id(params[:frame][:project_id])
      params[:frame][:project_id] = project ? project.id : nil
    end

    params[:frame].slice(
      :name, :description, :start_date, :end_date, :project_id
    )
  end
end
