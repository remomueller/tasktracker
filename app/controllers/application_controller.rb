class ApplicationController < ActionController::Base
  protect_from_forgery

  protected
  
  def check_system_admin
    unless current_user.system_admin?
      flash[:warning] = "You do not have sufficient privileges to access this page."
      redirect_to root_path
    end
  end
end
