class ProjectsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :api_authentication!, only: [:index, :show, :create, :update]

  def bulk
    @project = current_user.all_projects.find_by_id(params[:id])
    redirect_to projects_path unless @project
  end

  def reassign
    @project = current_user.all_projects.find_by_id(params[:id])
    respond_to do |format|
      if @project
        original_user = User.with_project(@project.id, [true]).find_by_id(params[:from_user_id])       # Editors only
        reassign_to_user = User.with_project(@project.id, [true]).find_by_id(params[:to_user_id])      # Editors only
        params[:sticky_status] = 'not_completed' unless ['not_completed', 'completed', 'all'].include?(params[:sticky_status])
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
      else
        format.html { redirect_to projects_path }
        format.js { render nothing: true }
      end
    end
  end

  def colorpicker
    @project = current_user.all_viewable_projects.find_by_id(params[:id])
    if @project
      current_user.colors["project_#{@project.id}"] = params[:color]
      current_user.update_attributes colors: current_user.colors
      render nothing: true
    else
      render nothing: true
    end
  end

  def visible
    @project = current_user.all_viewable_projects.find_by_id(params[:id])
    if @project
      hidden_project_ids = current_user.hidden_project_ids
      if params[:visible] == '1'
        hidden_project_ids.delete(@project.id)
      else
        hidden_project_ids << @project.id
      end
      current_user.update_attributes hidden_project_ids: hidden_project_ids
    else
      render nothing: true
    end
  end

  def favorite
    @project = current_user.all_viewable_projects.find_by_id(params[:id])
    if @project
      project_favorite = @project.project_favorites.find_or_create_by_user_id(current_user.id)
      project_favorite.update_attributes favorite: (params[:favorite] == '1')
    else
      render nothing: true
    end
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
    project_scope = project_scope.order("(favorite IS NULL or favorite = '0') ASC, " + @order)

    @count = project_scope.count
    @projects = project_scope.page(params[:page]).per(current_user.projects_per_page)

    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json { render json: project_scope.page(params[:page]).limit(50).as_json(current_user: current_user) }
    end
  end

  def show_old
    @project = current_user.all_viewable_projects.find_by_id(params[:id])
    respond_to do |format|
      if @project
        params[:board_id] = @project.boards.where(archived: false).natural_sort.first ? @project.boards.where(archived: false).natural_sort.first[1] : 0 if params[:board_id].blank?
        @board = @project.boards.find_by_id(params[:board_id] || 0)
        unless @board
        #   @board = @project.boards.active_today.first
        #   params[:board_id] = @board.id if @board
        end
        stickies_scope = @project.stickies
        @stickies = stickies_scope.with_board(params[:board_id] || 0).order('end_date DESC, start_date DESC').page(params[:page]).per(10)
        format.html # show.html.erb
        format.json { render json: @project }
      else
        format.html { redirect_to root_path }
        format.json { head :no_content }
      end
    end
  end

  def show
    params[:status] ||= ['planned','completed']
    @project = current_user.all_viewable_projects.find_by_id(params[:id])
    respond_to do |format|
      if @project
        params[:board_id] = @project.boards.where(archived: false).natural_sort.first ? @project.boards.where(archived: false).natural_sort.first[1] : 0 if params[:board_id].blank? and params[:board].blank?
        @board = @project.boards.find_by_name(params[:board])
        params[:board_id] = @board.id if @board
        @board = @project.boards.find_by_id(params[:board_id] || 0) unless @board
        stickies_scope = @project.stickies
        @stickies = stickies_scope.with_board(params[:board_id] || 0).order('end_date DESC, start_date DESC').page(params[:page]).per(10)
        format.html # show.html.erb
        format.json { render json: @project }
      else
        format.html { redirect_to root_path }
        format.json { head :no_content }
      end
    end
  end

  def new
    @project = current_user.projects.new
  end

  def edit
    @project = current_user.all_projects.find_by_id(params[:id])
    redirect_to root_path unless @project
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
    @project = current_user.all_projects.find_by_id(params[:id])

    if @project
      if @project.update_attributes(post_params)
        redirect_to(@project, notice: 'Project was successfully updated.')
      else
        render action: "edit"
      end
    else
      redirect_to root_path
    end
  end

  def destroy
    @project = current_user.all_projects.find_by_id(params[:id])
    @project.destroy if @project

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

end
