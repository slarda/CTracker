class OauthsController < ApplicationController
  skip_before_filter :require_login

  def oauth
    login_at(params[:provider])
  end

  def callback
    provider = auth_params['provider']
    begin
      # If user rejects social login (e.g. Facebook or Twitter 'cancel') then return to login page
      if params[:error] == 'access_denied' || params[:denied].present?
        flash[:notice] = 'You did not agree to login using a social network. Please create a new account.'
        redirect_to login_path
        return
      end

      if @user = login_from(provider)
        redirect_to root_path, :notice => "Logged in from #{provider.titleize}!"
      else
        begin
          @user = create_from(provider)

          reset_session # protect from session fixation attack
          auto_login(@user)
          redirect_to root_path, :notice => "Logged in from #{provider.titleize}!"
        rescue => e
          logger.error "Exception: #{e.message}"
          redirect_to root_path, :alert => "Failed to login from #{provider.titleize}!"
        end
      end

    rescue OAuth2::Error => oae
      logger.error "OAuth2::Error: #{oae.inspect}"
      render inline: oae.message
    end
  end

private
  def auth_params
    params.permit(:code, :provider,
                  # Twitter
                  :oauth_token, :oauth_verifier)
  end

end