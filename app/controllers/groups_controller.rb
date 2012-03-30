class GroupsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :api_authentication!, only: [:create, :show]

  def index
    current_user.update_attribute :groups_per_page, params[:groups_per_page].to_i if params[:groups_per_page].to_i >= 10 and params[:groups_per_page].to_i <= 200
    group_scope = current_user.all_viewable_groups
    @search_terms = params[:search].to_s.gsub(/[^0-9a-zA-Z]/, ' ').split(' ')
    @search_terms.each{|search_term| group_scope = group_scope.search(search_term) }

    group_scope = group_scope.with_project(@project.id, current_user.id) if @project = current_user.all_viewable_projects.find_by_id(params[:project_id])

    @order = Group.column_names.collect{|column_name| "groups.#{column_name}"}.include?(params[:order].to_s.split(' ').first) ? params[:order] : 'groups.id DESC'
    group_scope = group_scope.order(@order)

    @groups = group_scope.page(params[:page]).per(current_user.groups_per_page)
  end

  def show
    @group = current_user.all_viewable_groups.find_by_id(params[:id])
    if @group
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @group, methods: [:stickies, :template, :creator_name, :group_link], location: @group }
      end
    else
      respond_to do |format|
        format.html { redirect_to root_path }
        format.json { head :no_content }
      end
    end
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
      respond_to do |format|
        format.html { redirect_to @group, notice: @group.stickies.size.to_s + ' ' + ((@group.stickies.size == 1) ? 'sticky' : 'stickies') + " successfully created and added to #{frame_name}." }
        format.json { render json: @group }
      end
    else
      respond_to do |format|
        format.html { redirect_to root_path }
        format.json { render json: { error: 'Missing Template ID' }, status: :unprocessable_entity }
      end
    end
  end

  # def create
  #   @group = current_user.groups.new(params[:group])
  #   if @group.save
  #     redirect_to(@group, notice: 'Group was successfully created.')
  #   else
  #     render action: "new"
  #   end
  # end

  def update
    @group = current_user.all_groups.find_by_id(params[:id])
    if @group
      if @group.update_attributes(params[:group])
        redirect_to(@group, notice: 'Group was successfully updated.')
      else
        render action: "edit"
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
