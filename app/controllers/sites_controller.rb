class SitesController < ApplicationController
  before_filter :authenticate_user!, :except => [ :about ]
  
  def about
    
  end
  
  def dashboard
    @order = params[:order].blank? ? 'projects.name' : params[:order]
    project_scope = current_user.all_viewable_projects
    project_scope = project_scope.by_favorite(current_user.id).order(@order) #.order(@order) #.order('(favorite = true) ASC, ' + @order)
    @projects = project_scope
  end
end
