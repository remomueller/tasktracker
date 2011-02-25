class AuthenticationsController < ApplicationController
  def index
    @authentications = current_user.authentications if current_user
  end

  def failure
    flash[:warning] = params[:message] unless params[:message].blank?
    redirect_to authentications_path
  end

  def create
    omniauth = request.env["omniauth.auth"]
    omniauth['uid'] = omniauth['user_info']['email'] if omniauth['provider'] == 'google_apps' and omniauth['user_info']
    authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
    logger.info "OMNI AUTH INFO: #{omniauth.inspect}"
    omniauth['user_info']['email'] = omniauth['extra']['user_hash']['email'] if omniauth['user_info'] and omniauth['user_info']['email'].blank? and omniauth['extra'] and omniauth['extra']['user_hash']
    if authentication
      if authentication.user.active?
        flash[:notice] = "Signed in successfully."
      else
        flash[:warning] = "Your account has not yet been activated by a System Administrator."
      end
      sign_in_and_redirect(:user, authentication.user)
    elsif current_user
      current_user.authentications.create!(:provider => omniauth['provider'], :uid => omniauth['uid'])
      flash[:notice] = "Authentication successful."
      redirect_to authentications_path
    else
      user = User.new(params[:user])
      user.apply_omniauth(omniauth)
      if user.save
        if authentication.user.active?
          flash[:notice] = "Signed in successfully."
        else
          flash[:warning] = "Your account has not yet been activated by a System Administrator."
        end
        sign_in_and_redirect(:user, user)
      else
        session[:omniauth] = omniauth.except('extra')
        redirect_to new_user_registration_path
      end
    end
  end

  def destroy
    @authentication = current_user.authentications.find(params[:id])
    @authentication.destroy
    flash[:notice] = "Successfully destroyed authentication."
    redirect_to authentications_path
  end
end