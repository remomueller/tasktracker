class ProjectUsersController < ApplicationController
  before_filter :authenticate_user!

  def create
    @project = current_user.all_projects.find_by_id(params[:project_user][:project_id])
    invite_email = (params[:editors_text] || params[:viewers_text]).to_s.strip
    user_email = invite_email.split('[').last.to_s.split(']').first
    @user = current_user.associated_users.find_by_email(user_email)

    if @project and (not @user.blank? or not invite_email.blank?)
      if @user
        @project_user = @project.project_users.find_or_create_by_user_id(@user.id, { creator_id: current_user.id, allow_editing: (params[:project_user][:allow_editing] == 'true') })
      elsif not invite_email.blank?
        @project_user = @project.project_users.find_or_create_by_invite_email(invite_email, { creator_id: current_user.id, allow_editing: (params[:project_user][:allow_editing] == 'true') })
        @project_user.generate_invite_token!
      end
      render 'index'
    else
      render nothing: true
    end
  end

  def accept
    @project_user = ProjectUser.find_by_invite_token(params[:invite_token])
    if @project_user and @project_user.user == current_user
      redirect_to @project_user.project, notice: "You have already been added to #{@project_user.project.name}."
    elsif @project_user and @project_user.user
      redirect_to root_path, alert: "This invite has already been claimed."
    elsif @project_user
      @project_user.update_attribute :user_id, current_user.id
      redirect_to @project_user.project, notice: "You have been successfully been added to the project."
    else
      redirect_to root_path, alert: 'Invalid invitation token.'
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
