class SessionsController < ApplicationController
  skip_before_action :authorize
  
  def new
    render :layout => false
  end

  def create
    user = User.find_by(username: params[:username])
    if user and user.authenticate(params[:password])
      session[:expire_at] = Time.current + 24.hours
      session[:user_id] = user.id
      redirect_to root_url
    else
      redirect_to login_url, alert: "Invalid user/password combination"
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to login_url
  end
end