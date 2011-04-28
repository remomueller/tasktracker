class UsersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_system_admin, :only => [:new, :create, :edit, :update, :destroy]

  def graph
    @user = User.current.find_by_id(params[:id])
    redirect_to users_path unless @user
  end

  def update_settings
    notifications = {}
    email_settings = ['send_email', 'sticky_creation', 'project_comments', 'sticky_comments'] + current_user.all_viewable_projects.collect{|p| "project_#{p.id}"}
    email_settings.each do |email_setting|
      notifications[email_setting] = (not params[:email].blank? and params[:email][email_setting] == '1')
    end
    current_user.update_attribute :email_notifications, notifications
    redirect_to settings_path, :notice => 'Email settings saved.'
  end
  
  def index
    current_user.update_attribute :users_per_page, params[:users_per_page].to_i if params[:users_per_page].to_i >= 10 and params[:users_per_page].to_i <= 200
    @order = params[:order].blank? ? 'users.current_sign_in_at DESC' : params[:order]
    users_scope = User.current
    @search_terms = params[:search].to_s.gsub(/[^0-9a-zA-Z]/, ' ').split(' ')
    @search_terms.each{|search_term| users_scope = users_scope.search(search_term) }
    users_scope = users_scope.order(@order)
    @users = users_scope.page(params[:page]).per(current_user.users_per_page)
  end

  def show
    @user = User.current.find_by_id(params[:id])
    redirect_to users_path unless @user
  end
  
  def new
    @user = User.new
  end

  def edit
    @user = User.current.find_by_id(params[:id])
    redirect_to users_path unless @user
  end

  # # This is in registrations_controller.rb
  # def create
  # end

  def update
    @user = User.current.find_by_id(params[:id])
    if @user and @user.update_attributes(params[:user])
      @user.update_attribute :system_admin, params[:user][:system_admin]
      @user.update_attribute :status, params[:user][:status]
      redirect_to(@user, :notice => 'User was successfully updated.')
    elsif @user
      render :action => "edit"
    else
      redirect_to users_path
    end
  end
  
  def destroy
    @user = User.find_by_id(params[:id])
    @user.destroy if @user
    redirect_to users_path
  end  
end