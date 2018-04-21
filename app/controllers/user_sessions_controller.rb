class UserSessionsController < ApplicationController

  skip_before_filter :require_login #, except: [:destroy]
  skip_authorization_check only: [:new, :create, :destroy]

  def new
    @user = User.new
    #@twitter_url = sorcery_login_url('twitter')
  end

  def create
    if @user = login(params[:email], params[:password])
      redirect_to(root_path + "#/users/#{@user.id}/dashboard",  notice: 'Login successful')
      #redirect_back_or_to(root_path, notice: 'Login successful')
    else
      flash.now[:alert] = 'Please enter a valid email and password combination'
      @email = params[:email]
      @password = params[:password]
      render action: 'new'
    end
  end

  def destroy
    logout
    redirect_to(new_user_session_path)
  end
end