# frozen_string_literal: true

# Main application controller for Task Tracker.
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  skip_before_action :verify_authenticity_token, if: :devise_login?
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def devise_login?
    params[:controller] == 'devise/sessions' && params[:action] == 'create'
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(
      :sign_up,
      keys: [:first_name, :last_name, :email, :password, :password_confirmation] # , :emails_enabled
    )
  end

  def parse_date(date_string, default_date = '')
    if date_string.to_s.split('/').last.size == 2
      Date.strptime(date_string, '%m/%d/%y')
    else
      Date.strptime(date_string, '%m/%d/%Y')
    end
  rescue
    default_date
  end

  def check_system_admin
    return if current_user.system_admin?
    redirect_to root_path, alert: 'You do not have sufficient privileges to access that page.'
  end

  def scrub_order(model, params_order, default_order)
    (params_column, params_direction) = params_order.to_s.strip.downcase.split(' ')
    direction = (params_direction == 'desc' ? 'desc' : nil)
    column_name = model.column_names.collect { |c| "#{model.table_name}.#{c}" }.find { |c| c == params_column }
    column_name.blank? ? default_order : [column_name, direction].compact.join(' ')
  end

  def find_viewable_project_or_redirect(id = :project_id)
    @project = current_user.all_viewable_projects.find_by_id params[id]
    redirect_without_project unless @project
  end

  def find_editable_project_or_redirect(id = :project_id)
    @project = current_user.all_projects.find_by_id(params[id])
    redirect_without_project unless @project
  end

  def find_editable_project_or_first_project
    @project = current_user.all_projects.find_by_id params[:project_id]
    @project = current_user.all_projects.first if @project.nil? && current_user.all_projects.count == 1
  end

  # TODO: Deprecate this
  def set_viewable_project(id = :project_id)
    @project = current_user.all_viewable_projects.find_by_id(params[id])
  end

  def set_editable_project(id = :project_id)
    @project = current_user.all_projects.find_by_id(params[id])
  end
  # TODO: END

  def redirect_without_project(path = projects_path)
    empty_response_or_root_path(path) unless @project
  end

  def empty_response_or_root_path(path = root_path)
    respond_to do |format|
      format.html { redirect_to path }
      format.js { head :ok }
      format.json { head :no_content }
    end
  end
end
