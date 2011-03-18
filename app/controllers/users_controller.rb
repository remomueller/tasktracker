class UsersController < ApplicationController
  before_filter :authenticate_user!, :except => [:new, :create]
  before_filter :check_system_admin, :except => [:new, :create, :filtered, :index, :show]

  # # Retrieves filtered list of users.
  # def filtered
  #   @relation = params[:relation]
  #   
  #   users_scope = User.current.order('last_name, first_name')
  #   @search_terms = params[:search].to_s.gsub(/[^0-9a-zA-Z]/, ' ').split(' ')
  #   @search_terms.each{|search_term| users_scope = users_scope.search(search_term) }
  #   @users = users_scope
  #   
  #   render :partial => 'user_select_filter'
  # end
  
  def index
    @users = User.current
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