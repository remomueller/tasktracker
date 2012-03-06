class ProjectUsersController < ApplicationController
  before_filter :authenticate_user!

  def create
    @project = current_user.all_projects.find_by_id(params[:project_user][:project_id])
    user_email = (params[:editors_text] || params[:viewers_text]).to_s.split('<').last.to_s.split('>').first
    @user = User.current.find_by_email(user_email)

    if @project and @user
      @project_user = @project.project_users.find_or_create_by_user_id(@user.id)
      if @project_user
        @project_user.update_attribute :allow_editing, (params[:project_user][:allow_editing] == 'true')
        render 'index'
      end
    else
      render nothing: true
    end
  end

  def destroy
    @project_user = ProjectUser.find_by_id(params[:id])
    @project = current_user.all_projects.find_by_id(@project_user.project_id) if @project_user
    @project = current_user.all_viewable_projects.find_by_id(@project_user.project_id) if @project.blank? and @project_user and current_user == @project_user.user

    if @project and @project_user
      @project_user.destroy
      render 'index'
    else
      render nothing: true
    end
  end
end
