class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :check_system_admin, only: [:new, :create, :edit, :update, :destroy, :overall_graph, :graph]
  before_action :set_user, only: [ :show, :edit, :update, :destroy ]
  before_action :redirect_without_user, only: [ :show, :edit, :update, :destroy ]

  def api_token
    if User::VALID_API_TOKENS.include?(params[:api_token])
      @message = current_user.generate_api_token!(params[:api_token])
    else
      render nothing: true
    end
  end

  # Stickies per user
  def overall_graph
    @stickies = []
    @comments = []
    @users_hash = {}
    @users_comment_hash = {}
    params[:year] = Date.today.year if params[:year].blank?
    @year = params[:year]
    (1..12).each do |month|
      @stickies << Sticky.current.with_date_for_calendar(month_start_date(params[:year], month), month_end_date(params[:year], month))
      @comments << Comment.current.with_date_for_calendar(month_start_date(params[:year], month), month_end_date(params[:year], month))
      User.current.each do |user|
        escaped_name = "<" + user.id.to_s + ">" + user.nickname.gsub("'", "\\\\'")
        @users_hash[escaped_name] = [] unless @users_hash[escaped_name]
        @users_hash[escaped_name] << @stickies[month-1].with_owner(user.id).count == 0
        @users_comment_hash[escaped_name] = [] unless @users_comment_hash[escaped_name]
        @users_comment_hash[escaped_name] << @comments[month-1].with_creator(user.id).count
      end
    end
    @users_hash.reject!{|k, v| v == [0]*12}
    @users_comment_hash.reject!{|k, v| v == [0]*12}
  end

  def graph
    @user = User.current.find_by_id(params[:id])
    unless @user
      redirect_to users_path
      return
    end

    @stickies = []
    @planned = []
    @completed = []
    params[:year] = Date.today.year if params[:year].blank?
    @year = params[:year]
    (1..12).each do |month|
      @stickies << @user.all_stickies.with_date_for_calendar(month_start_date(params[:year], month), month_end_date(params[:year], month))
      @planned << @stickies.last.where(completed: false).count
      @completed << @stickies.last.where(completed: true).count
    end

    @other_projects_hash = {}
    @favorite_projects_hash = {}

    (1..12).each do |month|
      @user.all_projects.by_favorite(@user.id).order("(favorite IS NULL or favorite = 'f') DESC, name DESC").each do |project|
        escaped_name = project.name.gsub("'", "\\\\'")
        if project_favorite = project.project_favorites.find_by_user_id(@user.id) and project_favorite.favorite?
          @favorite_projects_hash[escaped_name] = [] unless @favorite_projects_hash[escaped_name]
          @favorite_projects_hash[escaped_name] << @stickies[month-1].where(project_id: project.id).count
        else
          @other_projects_hash[escaped_name] = [] unless @other_projects_hash[escaped_name]
          @other_projects_hash[escaped_name] << @stickies[month-1].where(project_id: project.id).count
        end
      end
    end
    @favorite_projects_hash.reject!{|k, v| v == [0]*12}
    @other_projects_hash.reject!{|k, v| v == [0]*12}
  end

  def update_settings
    notifications = {}
    email_settings = ['send_email'] + User::EMAILABLES.collect{|emailable, description| emailable.to_s} + current_user.all_viewable_projects.collect{|p| ["project_#{p.id}"] + User::EMAILABLES.collect{|emailable, description| "project_#{p.id}_#{emailable.to_s}"}}.flatten

    email_settings.each do |email_setting|
      notifications[email_setting] = (not params[:email].blank? and params[:email][email_setting] == '1')
    end
    current_user.update_attributes email_notifications: notifications
    redirect_to settings_path, notice: 'Email settings saved.'
  end

  def index
    unless current_user.system_admin? or params[:format] == 'json'
      redirect_to root_path, alert: "You do not have sufficient privileges to access that page."
      return
    end
    current_user.update_column :users_per_page, params[:users_per_page].to_i if params[:users_per_page].to_i >= 10 and params[:users_per_page].to_i <= 200

    @order = scrub_order(User, params[:order], 'users.current_sign_in_at DESC NULLS LAST')
    @users = User.current.search(params[:search] || params[:q]).order(@order).page(params[:page]).per( current_user.users_per_page )

    respond_to do |format|
      format.html
      format.js
      format.json do # TODO: Put into jbuilder instead!
        render json: params[:q].to_s.split(',').collect{ |u| (u.strip.downcase == 'me') ? { name: current_user.name, id: current_user.name } : { name: u.strip.titleize, id: u.strip.titleize } } + @users.collect{ |u| { name: u.name, id: u.name } }
      end
    end
  end

  def show
  end

  # def new
  #   @user = User.new
  # end

  def edit
  end

  # # This is in registrations_controller.rb
  # def create
  # end

  def update
    if @user.update(user_params)
      original_status = @user.status
      @user.update( system_admin: params[:user][:system_admin], service_account: params[:user][:service_account], status: params[:user][:status] )
      UserMailer.status_activated(@user).deliver if Rails.env.production? and original_status != @user.status and @user.status == 'active'
      redirect_to @user, notice: 'User was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @user.destroy
    redirect_to users_path
  end

  private

    def set_user
      @user = User.current.find_by_id(params[:id])
    end

    def redirect_without_user
      empty_response_or_root_path(users_path) unless @user
    end

    def user_params
      params.require(:user).permit(
        :first_name, :last_name, :email
      )
    end
end
