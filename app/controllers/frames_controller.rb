class FramesController < ApplicationController
  before_filter :authenticate_user!

  def index
    @frames = current_user.all_viewable_frames
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
    @frame = current_user.frames.new(params[:frame])
    if @frame.save
      redirect_to(@frame, :notice => 'Frame was successfully created.')
    else
      render :action => "new"
    end
  end

  def update
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
