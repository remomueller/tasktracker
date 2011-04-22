class FramesController < ApplicationController
  before_filter :authenticate_user!

  def index
    current_user.update_attribute :frames_per_page, params[:frames_per_page].to_i if params[:frames_per_page].to_i >= 10 and params[:frames_per_page].to_i <= 200
    frames_scope = current_user.all_viewable_frames
    @search_terms = params[:search].to_s.gsub(/[^0-9a-zA-Z]/, ' ').split(' ')
    @search_terms.each{|search_term| frames_scope = frames_scope.search(search_term) }
    @frames = frames_scope.page(params[:page]).per(current_user.frames_per_page)
  end

  def show
    @frame = current_user.all_viewable_frames.find_by_id(params[:id])
    redirect_to root_path unless @frame
  end

  def new
    @frame = current_user.frames.new(params[:frame])
  end

  def edit
    @frame = current_user.all_frames.find_by_id(params[:id])
    redirect_to root_path unless @frame
  end

  def create
    params[:frame][:start_date] = Date.strptime(params[:frame][:start_date], "%m/%d/%Y") if params[:frame] and not params[:frame][:start_date].blank?
    params[:frame][:end_date] = Date.strptime(params[:frame][:end_date], "%m/%d/%Y") if params[:frame] and not params[:frame][:end_date].blank?
    
    @frame = current_user.frames.new(params[:frame])
    if @frame.save
      redirect_to(@frame, :notice => 'Frame was successfully created.')
    else
      render :action => "new"
    end
  end

  def update
    params[:frame][:start_date] = Date.strptime(params[:frame][:start_date], "%m/%d/%Y") if params[:frame] and not params[:frame][:start_date].blank?
    params[:frame][:end_date] = Date.strptime(params[:frame][:end_date], "%m/%d/%Y") if params[:frame] and not params[:frame][:end_date].blank?
    
    @frame = current_user.all_frames.find_by_id(params[:id])
    if @frame
      if @frame.update_attributes(params[:frame])
        redirect_to(@frame, :notice => 'Frame was successfully updated.')
      else
        render :action => "edit"
      end
    else
      redirect_to root_path
    end
  end

  def destroy
    @frame = current_user.all_frames.find_by_id(params[:id])
    if @frame
      @frame.destroy
      redirect_to frames_path
    else
      redirect_to root_path
    end
  end
end
