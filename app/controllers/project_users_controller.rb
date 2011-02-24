class ProjectUsersController < ApplicationController
  before_filter :authenticate_user!

  # def index
  #   @project_users = ProjectUser.all
  # 
  #   respond_to do |format|
  #     format.html # index.html.erb
  #     format.xml  { render :xml => @project_users }
  #   end
  # end
  # 
  # def show
  #   @project_user = ProjectUser.find(params[:id])
  # 
  #   respond_to do |format|
  #     format.html # show.html.erb
  #     format.xml  { render :xml => @project_user }
  #   end
  # end
  # 
  # def new
  #   @project_user = ProjectUser.new
  # 
  #   respond_to do |format|
  #     format.html # new.html.erb
  #     format.xml  { render :xml => @project_user }
  #   end
  # end
  # 
  # def edit
  #   @project_user = ProjectUser.find(params[:id])
  # end
  # 
  def create
    
    @project_user = ProjectUser.find_or_create_by_project_id_and_user_id_and_allow_editing(params[:project_user][:project_id], params[:user_id], params[:project_user][:allow_editing])
  
    if @project_user and current_user.all_projects.include?(@project_user.project)
      if @project_user.save
          redirect_to(@project_user.project, :notice => "User was successfully added to the project.")
      else
        render :nothing => true
      end
    end
  end
  # 
  # def update
  #   @project_user = ProjectUser.find(params[:id])
  # 
  #   respond_to do |format|
  #     if @project_user.update_attributes(params[:project_user])
  #       format.html { redirect_to(@project_user, :notice => 'Project user was successfully updated.') }
  #       format.xml  { head :ok }
  #     else
  #       format.html { render :action => "edit" }
  #       format.xml  { render :xml => @project_user.errors, :status => :unprocessable_entity }
  #     end
  #   end
  # end
  # 
  # def destroy
  #   @project_user = ProjectUser.find(params[:id])
  #   @project_user.destroy
  # 
  #   respond_to do |format|
  #     format.html { redirect_to(project_users_url) }
  #     format.xml  { head :ok }
  #   end
  # end
end
