class GroupsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :api_authentication!, only: [:create, :show]

  def project_selection
    @group = Group.new(post_params)
    @project_id = @group.project_id
  end

  def index
    current_user.update_column :groups_per_page, params[:groups_per_page].to_i if params[:groups_per_page].to_i >= 10 and params[:groups_per_page].to_i <= 200
    group_scope = current_user.all_viewable_groups
    @search_terms = params[:search].to_s.gsub(/[^0-9a-zA-Z]/, ' ').split(' ')
    @search_terms.each{|search_term| group_scope = group_scope.search(search_term) }

    group_scope = group_scope.where(project_id: @project.id) if @project = current_user.all_viewable_projects.find_by_id(params[:project_id])

    group_scope = group_scope.where(template_id: params[:template_id]) unless params[:template_id].blank?

    @order = scrub_order(Group, params[:order], 'groups.id DESC')
    group_scope = group_scope.order(@order)

    @count = group_scope.count
    @groups = (params[:use_template] == 'redesign' ? group_scope.page(params[:page]).per(50) : group_scope.page(params[:page]).per(current_user.groups_per_page))

    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json { render json: @groups }
    end
  end

  def show
    @group = current_user.all_viewable_groups.find_by_id(params[:id])
    if @group
      respond_to do |format|
        format.html # show.html.erb
        format.js
        format.json { render json: @group, methods: [:stickies, :template, :creator_name, :group_link], location: @group }
      end
    else
      respond_to do |format|
        format.html { redirect_to root_path }
        format.js { render nothing: true }
        format.json { head :no_content }
      end
    end
  end

  def new
    @group = current_user.groups.new(post_params)
    @group.project = current_user.all_projects.first if not @group.project and current_user.all_projects.size == 1
    @project_id = @group.project_id

    respond_to do |format|
      format.js { render 'new_redesign' }
      format.html { redirect_to root_path }
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
    group_params = post_params

    @template = current_user.all_templates.find_by_id(group_params[:template_id])

    if @template
      @group = @template.generate_stickies!(current_user, group_params[:board_id], group_params[:initial_due_date], group_params[:description])
      respond_to do |format|
        format.html { redirect_to @group, notice: @group.stickies.size.to_s + ' ' + ((@group.stickies.size == 1) ? 'sticky' : 'stickies') + " successfully created and added to #{(@board ? @board.name : 'Holding Pen')}." }
        format.js { render "create" }
        format.json { render json: @group }
      end
    else
      respond_to do |format|
        format.html { redirect_to root_path }
        format.js { render "new" }
        format.json { render json: { error: 'Missing Template ID' }, status: :unprocessable_entity }
      end
    end
  end

  # def create
  #   @group = current_user.groups.new(post_params)
  #   if @group.save
  #     redirect_to(@group, notice: 'Group was successfully created.')
  #   else
  #     render action: "new"
  #   end
  # end

  def update
    @group = current_user.all_groups.find_by_id(params[:id])
    if @group
      if @group.update_attributes(post_params)
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
    @group.destroy if @group

    respond_to do |format|
      format.html { redirect_to groups_path }
      format.json { head :no_content }
    end
  end

  def post_params
    params[:group] ||= {}

    unless params[:group][:project_id].blank?
      project = current_user.all_projects.find_by_id(params[:group][:project_id])
      params[:group][:project_id] = project ? project.id : nil
    end

    if project and params[:create_new_board] == '1'
      if params[:group_board_name].to_s.strip.blank?
        params[:group][:board_id] = nil
      else
        @board = project.boards.find_or_create_by_name(params[:group_board_name].to_s.strip, { user_id: current_user.id })
        params[:group][:board_id] = @board.id
      end
    elsif project
      @board = project.boards.find_by_id(params[:group][:board_id])
    end

    params[:group][:board_id] = (@board ? @board.id : nil)

    [:initial_due_date].each do |date|
      params[:group][date] = parse_date(params[:group][date], Date.today)
    end

    params[:group].slice(
      :description, :project_id, :board_id, :template_id, :initial_due_date
    )
  end
end
