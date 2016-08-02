# frozen_string_literal: true

# Allows a user to view and update account preferences.
class AccountController < ApplicationController
  before_action :authenticate_user!

  def change_password
    if current_user.valid_password?(params[:user][:current_password])
      if current_user.reset_password(params[:user][:password], params[:user][:password_confirmation])
        bypass_sign_in current_user
        redirect_to settings_path, notice: 'Your password has been changed.'
      else
        render :settings
      end
    else
      current_user.errors.add :current_password, 'is invalid'
      render :settings
    end
  end

  def settings
  end

  def update_settings
    current_user.update user_params
    redirect_to settings_path, notice: 'Your settings have been saved.'
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :emails_enabled, :calendar_view)
  end
end
