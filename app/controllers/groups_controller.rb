class GroupsController < ApplicationController
  before_filter :authenticate_user!

  def index
    group_scope = current_user.all_viewable_groups
    @groups = group_scope.page(params[:page]).per(20) #current_user.groups_per_page)
  end

  def show
    @group = current_user.all_viewable_groups.find_by_id(params[:id])
    redirect_to root_path unless @group
  end

  # def new
  #   @group = current_user.groups.new(params[:group])
  # end
  
  def edit
    @group = current_user.all_groups.find_by_id(params[:id])
    redirect_to root_path unless @group
  end
  
  # def create
  #   @group = current_user.groups.new(params[:group])
  #   if @group.save
  #     redirect_to(@group, :notice => 'Group was successfully created.')
  #   else
  #     render :action => "new"
  #   end
  # end
  
  def update
    @group = current_user.all_groups.find_by_id(params[:id])
    if @group
      
      @group.update_attributes(params[:group])
      redirect_to(@group, :notice => 'Group was successfully updated.')
      
      # if @group.update_attributes(params[:group])
      #   redirect_to(@group, :notice => 'Group was successfully updated.')
      # else
      #   render :action => "edit"
      # end
    else
      redirect_to root_path
    end
  end
  
  def destroy
    @group = current_user.all_groups.find_by_id(params[:id])
    if @group
      @group.destroy
      redirect_to groups_path
    else
      redirect_to root_path
    end
  end
end
