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
    @project = current_user.all_projects.find(params[:project_user][:project_id])
    
    if @project
    
    
      @project_user = @project.project_users.find_or_create_by_user_id(params[:user_id])
  
      if @project_user
        @project_user.allow_editing = params[:project_user][:allow_editing]
        if @project_user.save
          render :update do |page|
            @relation = 'editors'
            page.replace_html "#{@relation}_list", :partial => "project_users/index"
            @relation = 'viewers'
            page.replace_html "#{@relation}_list", :partial => "project_users/index"
          end
        else
          render :nothing => true
        end
      end
    else
      render :nothing => true
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
  def destroy
    @project_user.find_by_id(params[:id])
    @project = current_user.all_projects.find(@project_user.project_id) if @project_user
    
    if @project and @project_user
      @project_user.destroy
      render :update do |page|
        
      end
    else
      render :nothing => true
    end
  end
end
