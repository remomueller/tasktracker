class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authenticate_user!, only: [:search]


  layout "contour/layouts/application"

  def about

  end

  def search
    @projects = current_user.all_viewable_projects.search_name(params[:q]).order('name').limit(10)
    @groups = current_user.all_viewable_groups.search(params[:q]).order('description').limit(10)

    @objects = @projects + @groups

    respond_to do |format|
      format.json { render json: ([params[:q]] + @projects.collect(&:name)).uniq }
      format.html do
        # redirect_to [@objects.first.project, @objects.first] if @objects.size == 1 and @objects.first.respond_to?('project')
        if @objects.size == 0
          redirect_to tasks_path( search: params[:q] )
        elsif @objects.size == 1
          redirect_to @objects.first
        end
      end
    end
  end

  protected

  def month_start_date(year, month)
    Date.parse("#{year}-#{month}-01")
  end

  def month_end_date(year, month)
    Date.parse("#{year.to_i+month.to_i/12}-#{(month.to_i)%12+1}-01")-1.day
  end

  def parse_date(date_string, default_date = '')
    date_string.to_s.split('/').last.size == 2 ? Date.strptime(date_string, "%m/%d/%y") : Date.strptime(date_string, "%m/%d/%Y") rescue default_date
  end

  def check_system_admin
    redirect_to root_path, alert: "You do not have sufficient privileges to access that page." unless current_user.system_admin?
  end

  def scrub_order(model, params_order, default_order)
    (params_column, params_direction) = params_order.to_s.strip.downcase.split(' ')
    direction = (params_direction == 'desc' ? 'DESC' : nil)
    column_name = (model.column_names.collect{|c| model.table_name + "." + c}.select{|c| c == params_column}.first)
    order = column_name.blank? ? default_order : [column_name, direction].compact.join(' ')
    order
  end

  def set_viewable_project(id = :project_id)
    @project = current_user.all_viewable_projects.find_by_id(params[id])
  end

  def set_editable_project(id = :project_id)
    @project = current_user.all_projects.find_by_id(params[id])
  end

  def redirect_without_project(path = root_path)
    empty_response_or_root_path(path) unless @project
  end

  def empty_response_or_root_path(path = root_path)
    respond_to do |format|
      format.html { redirect_to path }
      format.js { render nothing: true }
      format.json { head :no_content }
    end
  end

end
