class ProjectsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :api_authentication!, only: [ :index, :show, :create, :update ]
  before_filter :set_viewable_project, only: [ :show, :colorpicker, :visible, :favorite, :settings ]
  before_filter :set_editable_project, only: [ :edit, :update, :destroy, :bulk, :reassign ]

  def bulk
    redirect_to projects_path unless @project
  end

  def reassign
    original_user = User.with_project(@project.id, [true]).find_by_id(params[:from_user_id])       # Editors only
    reassign_to_user = User.with_project(@project.id, [true]).find_by_id(params[:to_user_id])      # Editors only
    params[:sticky_status] = 'not_completed' unless ['not_completed', 'completed', 'all'].include?(params[:sticky_status])

    respond_to do |format|
      if original_user and reassign_to_user
        sticky_scope = Sticky.where(project_id: @project.id, owner_id: original_user.id)
        if params[:sticky_status] == 'completed'
          sticky_scope = sticky_scope.where(completed: true)
        elsif params[:sticky_status] == 'not_completed'
          sticky_scope = sticky_scope.where(completed: false)
        end
        @sticky_count = sticky_scope.count
        sticky_scope.update_all(owner_id: reassign_to_user.id)
        format.html { redirect_to @project, notice: "#{@sticky_count} #{@sticky_count == 1 ? 'Sticky' : 'Stickies'} successfully reassigned." }
        format.js # reassign.js.erb
      else
        format.html do
          flash[:error] = 'Please select the original owner and new owner of the stickies.'
          render 'bulk'
        end
        format. js # reassign.js.erb
      end
    end
  end

  def colorpicker
    current_user.colors["project_#{@project.id}"] = params[:color]
    current_user.update_attributes colors: current_user.colors
    render nothing: true
  end

  def visible
    hidden_project_ids = current_user.hidden_project_ids
    if params[:visible] == '1'
      hidden_project_ids.delete(@project.id)
    else
      hidden_project_ids << @project.id
    end
    current_user.update_attributes hidden_project_ids: hidden_project_ids
  end

  def favorite
    project_favorite = @project.project_favorites.find_or_create_by_user_id(current_user.id)
    project_favorite.update_attributes favorite: (params[:favorite] == '1')
  end

  def selection
    @sticky = Sticky.new(params[:sticky].slice(:board_id, :owner_id, :tag_ids))
    @project = current_user.all_projects.find_by_id(params[:sticky][:project_id])
    @project_id = @project.id if @project
  end

  def index
    current_user.update_column :projects_per_page, params[:projects_per_page].to_i if params[:projects_per_page].to_i >= 5 and params[:projects_per_page].to_i <= 200
    project_scope = current_user.all_viewable_projects

    @search_terms = params[:search].to_s.gsub(/[^0-9a-zA-Z]/, ' ').split(' ')
    @search_terms.each{|search_term| project_scope = project_scope.search(search_term) }

    project_scope = project_scope.by_favorite(current_user.id)
    @order = scrub_order(Project, params[:order], 'projects.name')
    project_scope = project_scope.order("(favorite IS NULL or favorite = 'f') ASC, " + @order)

    @count = project_scope.count
    @projects = project_scope.page(params[:page]).per(current_user.projects_per_page)

    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json { render json: project_scope.page(params[:page]).limit(50).as_json(current_user: current_user) }
    end
  end

  def settings
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @project }
    end
  end

  def show
    params[:status] ||= ['planned','completed']

    respond_to do |format|
      @template = @project.templates.find_by_id(params[:template_id])

      unless @template
        @board = @project.boards.find_by_name(params[:board])
        params[:board_id] = @board ? @board.id : (params[:board_id] || 0)
        @board = @project.boards.find_by_id(params[:board_id]) unless @board
      end

      format.html # show.html.erb
      format.json { render json: @project }
    end
  end

  def new
    @project = current_user.projects.new
  end

  def edit

  end

  def create
    @project = current_user.projects.new(post_params)

    respond_to do |format|
      if @project.save
        format.html { redirect_to(@project, notice: 'Project was successfully created.') }
        format.js { render 'create' }
        format.json { render json: @project, status: :created, location: @project }
      else
        format.html { render "new" }
        format.js { render "new" }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @project.update_attributes(post_params)
      redirect_to(@project, notice: 'Project was successfully updated.')
    else
      render action: "edit"
    end
  end

  def destroy
    @project.destroy

    respond_to do |format|
      format.html { redirect_to projects_path }
      format.json { head :no_content }
    end
  end

  private

  def post_params
    params[:project] ||= {}

    [:start_date, :end_date].each do |date|
      params[:project][date] = parse_date(params[:project][date])
    end

    params[:project].slice(
      :name, :description, :status, :start_date, :end_date
    )
  end

  def set_viewable_project
    redirect_to_projects_path unless @project = current_user.all_viewable_projects.find_by_id(params[:id])
  end

  def set_editable_project
    redirect_to_projects_path unless @project = current_user.all_projects.find_by_id(params[:id])
  end

  def redirect_to_projects_path
    respond_to do |format|
      format.html { redirect_to projects_path }
      format.js { render nothing: true }
      format.json { head :no_content }
    end
  end
end
