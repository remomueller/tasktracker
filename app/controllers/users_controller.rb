class UsersController < ApplicationController
  before_filter :authenticate_user!, :except => [:new, :create]
  before_filter :check_system_admin, :except => [:new, :create, :filtered, :index, :show, :settings, :update_settings]

  def settings
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
    @order = params[:order].blank? ? 'users.last_name, users.first_name' : params[:order]
    users_scope = User.current
    @search_terms = params[:search].to_s.gsub(/[^0-9a-zA-Z]/, ' ').split(' ')
    @search_terms.each{|search_term| users_scope = users_scope.search(search_term) }
    users_scope = users_scope.order(@order)
    @users = users_scope.page(params[:page]).per(current_user.users_per_page)
  end

  def show
    @user = User.find_by_id(params[:id])
  end
  
  # # GET /users/new
  # # GET /users/new.xml
  # def new
  #   @user = User.new
  # 
  #   respond_to do |format|
  #     format.html # new.html.erb
  #     format.xml  { render :xml => @user }
  #   end
  # end

  def edit
    @user = User.find_by_id(params[:id])
  end
  
  # # POST /users
  # # POST /users.xml
  # def create
  #   @user = User.new(params[:user])
  # 
  #   respond_to do |format|
  #     if @user.save
  #       format.html { redirect_to(@user, :notice => 'User was successfully created.') }
  #       format.xml  { render :xml => @user, :status => :created, :location => @user }
  #     else
  #       format.html { render :action => "new" }
  #       format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
  #     end
  #   end
  # end

  def update
    @user = User.find_by_id(params[:id])
    if @user.update_attributes(params[:user])
      @user.update_attribute :system_admin, params[:user][:system_admin]
      @user.update_attribute :status, params[:user][:status]
      redirect_to(@user, :notice => 'User was successfully updated.')
    else
      render :action => "edit"
    end
  end
  
  def destroy
    @user = User.find_by_id(params[:id])
    @user.destroy
    redirect_to users_path
  end  
end