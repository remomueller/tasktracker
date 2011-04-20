class SitesController < ApplicationController
  before_filter :authenticate_user!, :except => [ :about ]
  
  def about
    
  end
end
