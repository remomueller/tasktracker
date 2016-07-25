# frozen_string_literal: true

# Allows collaborators to be added to projects.
class ProjectUsersController < ApplicationController
  before_action :authenticate_user!

  # POST /project_users.js
  # POST /project_users.json
  def create
    @project = current_user.all_projects.find_by_id(params[:project_user][:project_id])
    invite_email = (params[:editors_text] || params[:viewers_text]).to_s.strip
    user_email = invite_email.split('[').last.to_s.split(']').first
    @user = current_user.associated_users.find_by_email(user_email)
    if @project && (@user.present? || invite_email.present?)
      if @user
        @project_user = @project.project_users.where(user_id: @user.id).first_or_create(creator_id: current_user.id, allow_editing: (params[:project_user][:allow_editing] == 'true'))
        @project_user.notify_user_added_to_project
      elsif invite_email.present?
        @project_user = @project.project_users.where(invite_email: invite_email).first_or_create(creator_id: current_user.id, allow_editing: (params[:project_user][:allow_editing] == 'true'))
        @project_user.generate_invite_token!
      end
      render :index
    else
      head :ok
    end
  end

  def accept
    @project_user = ProjectUser.find_by_invite_token(params[:invite_token])
    if @project_user && @project_user.user == current_user
      redirect_to @project_user.project, notice: "You have already been added to #{@project_user.project.name}."
    elsif @project_user && @project_user.user
      redirect_to root_path, alert: 'This invite has already been claimed.'
    elsif @project_user
      @project_user.update user_id: current_user.id
      redirect_to @project_user.project, notice: 'You have been successfully been added to the project.'
    else
      redirect_to root_path, alert: 'Invalid invitation token.'
    end
  end

  # DELETE /project_users/1.js
  def destroy
    @project_user = ProjectUser.find_by_id(params[:id])
    @project = current_user.all_projects.find_by_id(@project_user.project_id) if @project_user
    @project = current_user.all_viewable_projects.find_by_id(@project_user.project_id) if @project.blank? && @project_user && current_user == @project_user.user
    if @project && @project_user
      @project_user.destroy
      render :index
    else
      head :ok
    end
  end
end
