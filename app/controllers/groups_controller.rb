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

  def create
    params[:initial_due_date] = begin Date.strptime(params[:initial_due_date], "%m/%d/%Y") rescue Date.today end
    @template = current_user.all_templates.find_by_id(params[:template_id])
    @frame = (@template ? @template.project.frames.find_by_id(params[:frame_id]) : nil)
    @frame_id = @frame.id if @frame
    frame_name = (@frame ? @frame.name + ' - ' + @frame.short_time : 'Backlog')
    if @template
      @group = @template.generate_stickies!(current_user, @frame_id, params[:initial_due_date], params[:additional_text])
      redirect_to @group, notice: @group.stickies.size.to_s + ' ' + ((@group.stickies.size == 1) ? 'sticky' : 'stickies') + " successfully created and added to #{frame_name}."
    else
      redirect_to root_path
    end  
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
      if @group.update_attributes(params[:group])
        redirect_to(@group, :notice => 'Group was successfully updated.')
      else
        render :action => "edit"
      end
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
