class StickiesController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    @stickies = current_user.all_stickies.all
  end

  def show
    @sticky = current_user.all_stickies.find(params[:id])
    redirect_to root_path unless @sticky
  end

  def new
    @sticky = current_user.stickies.new
  end

  def edit
    @sticky = current_user.all_stickies.find(params[:id])
    redirect_to root_path unless @sticky
  end

  def create
    @sticky = current_user.stickies.new(params[:sticky])
    if @sticky.save
      redirect_to(@sticky, :notice => 'Sticky was successfully created.')
    else
      render :action => "new"
    end
  end

  def update
    @sticky = current_user.all_stickies.find(params[:id])
    if @sticky
      if @sticky.update_attributes(params[:sticky])
        redirect_to(@sticky, :notice => 'Sticky was successfully updated.')
      else
        render :action => "edit"
      end
    else
      redirect_to root_path
    end
  end

  def destroy
    @sticky = current_user.all_stickies.find(params[:id])
    if @sticky
      @sticky.destroy
      redirect_to(stickies_url)
    else
      redirect_to root_path
    end
  end
end
