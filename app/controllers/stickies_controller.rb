class StickiesController < ApplicationController
  before_filter :authenticate_user!

  def add_comment
    @sticky = current_user.all_viewable_stickies.find_by_id(params[:id])
    if @sticky and not params[:comment].blank?
      @sticky.new_comment(current_user, params[:comment])

      @object = @sticky
      @position = params[:position]
      @comments = @object.comments
      render "comments/add_comment"
    else
      render :nothing => true
    end
  end
  
  def index
    @stickies = current_user.all_viewable_stickies
  end

  def show
    @sticky = current_user.all_viewable_stickies.find_by_id(params[:id])
    redirect_to root_path unless @sticky
  end

  def new
    @sticky = current_user.stickies.new(params[:sticky])
    logger.debug "#{@sticky.inspect}"
  end

  def edit
    @sticky = current_user.all_stickies.find_by_id(params[:id])
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
    @sticky = current_user.all_stickies.find_by_id(params[:id])
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
    @sticky = current_user.all_stickies.find_by_id(params[:id])
    if @sticky
      @sticky.destroy
      redirect_to(stickies_url)
    else
      redirect_to root_path
    end
  end
end
