class UsersController < ApplicationController
  before_filter :authenticate_user!, :except => [:new, :create]

  # Retrieves filtered list of users.
  def filtered
    @search = params[:search]
    @relation = params[:relation]
    render :partial => 'user_select_filter'
  end
  
end
