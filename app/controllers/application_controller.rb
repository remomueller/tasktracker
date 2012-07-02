class ApplicationController < ActionController::Base
  protect_from_forgery

  layout "contour/layouts/application"

  def about

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

  def api_authentication!
    if current_user.service_account? and User::VALID_API_TOKENS.include?(params[:api_token]) and user = User.find_by_api_token(params[:api_token], params[params[:api_token]])
      sign_in(:user, user)
      @current_user = nil
    end
  end

  def scrub_order(model, params_order, default_order)
    (params_column, params_direction) = params_order.to_s.strip.downcase.split(' ')
    direction = (params_direction == 'desc' ? 'DESC' : nil)
    column_name = (model.column_names.collect{|c| model.table_name + "." + c}.select{|c| c == params_column}.first)
    order = column_name.blank? ? default_order : [column_name, direction].compact.join(' ')
    order
  end
end
