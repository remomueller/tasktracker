# frozen_string_literal: true

# Allows collaborators to be added to projects.
class ProjectUsersController < ApplicationController
  before_action :authenticate_user!
  before_action :find_editable_project_or_redirect, only: [:create]

  # POST /project_users.js
  def create
    create_member_invite
    render :index
  end

  # POST /project_users/1.js
  def resend
    @project_user = ProjectUser.find_by_id(params[:id])
    @project = current_user.all_projects.find_by_id(@project_user.project_id) if @project_user

    if @project && @project_user
      @project_user.generate_invite_token!
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

  private

  def editor?
    (params[:editor] == '1')
  end

  def invite_email
    params[:invite_email].to_s.strip
  end

  def associated_user
    current_user.associated_users.find_by_email(invite_email.split('[').last.to_s.split(']').first)
  end

  def create_member_invite
    if associated_user
      add_existing_project_user(associated_user)
    elsif invite_email.present?
      invite_new_project_user
    end
  end

  def add_existing_project_user(user)
    @project_user = @project.project_users.where(user_id: user.id).first_or_create(creator_id: current_user.id)
    @project_user.update allow_editing: editor?
  end

  def invite_new_project_user
    @project_user = @project.project_users.where(invite_email: invite_email).first_or_create(creator_id: current_user.id)
    @project_user.update allow_editing: editor?
    @project_user.generate_invite_token!
  end
end
