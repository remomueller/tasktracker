# frozen_string_literal: true

# Allows users to update their settings, and admins to update user accounts.
class UsersController < ApplicationController
  before_action :authenticate_user!
  # TODO: This should only be viewalbe by system admin
  before_action :check_system_admin, only: [:edit, :update, :destroy]
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :redirect_without_user, only: [:show, :edit, :update, :destroy]

  def index
    unless current_user.system_admin? || params[:format] == 'json'
      redirect_to root_path, alert: 'You do not have sufficient privileges to access that page.'
      return
    end

    @order = scrub_order(User, params[:order], 'users.current_sign_in_at DESC NULLS LAST')
    @users = User.current.search(params[:search] || params[:q]).order(@order).page(params[:page]).per( 40 )

    respond_to do |format|
      format.html
      format.json do # TODO: Put into jbuilder instead!
        render json: params[:q].to_s.split(',').collect{ |u| (u.strip.downcase == 'me') ? { name: current_user.name, id: current_user.name } : { name: u.strip.titleize, id: u.strip.titleize } } + @users.collect{ |u| { name: u.name, id: u.name } }
      end
    end
  end

  def show
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to @user, notice: 'User was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @user.destroy
    redirect_to users_path
  end

  private

  def set_user
    if current_user.system_admin?
      @user = User.current.find_by_id(params[:id])
    else
      @user = current_user.associated_users.find_by_id(params[:id])
    end
  end

  def redirect_without_user
    empty_response_or_root_path(users_path) unless @user
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :system_admin)
  end
end
