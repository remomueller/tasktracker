class SitesController < ApplicationController
  before_filter :authenticate_user!, :except => [ :about ]
  
  def about
    
  end
  
  def dashboard
    logger.debug "PARAMS: #{params.inspect}"
    @order = params[:order].blank? ? 'name' : params[:order]
    
    project_scope = current_user.all_viewable_projects
    
    # if params[:order] == 'popularity'
    #   project_scope = project_scope.popularity
    # elsif params[:order] == 'popularity DESC'
    #   project_scope = project_scope.popularity_desc
    # else
      project_scope = project_scope.order(@order)
    # end
    
    @projects = project_scope
  end
end
