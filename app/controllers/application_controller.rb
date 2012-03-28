class ApplicationController < ActionController::Base
  protect_from_forgery

  layout "contour/layouts/application"

  def month_start_date(year, month)
    Date.parse("#{year}-#{month}-01")
  end

  def month_end_date(year, month)
    Date.parse("#{year.to_i+month.to_i/12}-#{(month.to_i)%12+1}-01")-1.day
  end

  protected

  def check_system_admin
    redirect_to root_path, alert: "You do not have sufficient privileges to access that page." unless current_user.system_admin?
  end

  def api_authentication!
    if current_user.service_account? and User::VALID_API_TOKENS.include?(params[:api_token]) and user = User.find_by_api_token(params[:api_token], params[params[:api_token]])
      sign_in(:user, user)
      @current_user = nil
    end
  end
end
