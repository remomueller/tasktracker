class ApplicationController < ActionController::Base
  protect_from_forgery

  layout "contour/layouts/application"

  def month_start_date(year, month)
    Date.parse("#{year}-#{month}-01")
  end
  
  def month_end_date(year, month)
    Date.parse("#{year.to_i+month.to_i/12}-#{(month.to_i)%12+1}-01")-1.day
  end
  
  def year_start_date(year)
    Date.parse("#{year}-01-01")
  end
  
  def year_end_date(year)
    Date.parse("#{year.to_i+1}-01-01")-1.day
  end

  protected
  
  def check_system_admin
    redirect_to root_path, :alert => "You do not have sufficient privileges to access that page." unless current_user.system_admin?
  end
end
