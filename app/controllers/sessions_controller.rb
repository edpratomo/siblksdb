class SessionsController < ApplicationController
  def new
    render :layout => false
  end

  def create
    user = User.find_by(username: params[:username])
    if user and user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to users_url
    else
      #redirect_to login_url, alert "Invalid user/password combination"
    end
  end

  def destroy
  end
end
