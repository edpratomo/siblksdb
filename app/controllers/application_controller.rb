class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :authorize
  
  protected
  def authorize
    unless User.find_by(id: session[:user_id])
      redirect_to login_url
    end
  end

  def authorize_admin
    user = User.find_by(id: session[:user_id])
    group = user.group.name
    unless group == "admin" or group == "sysadmin"
      redirect_to root_url, alert: "Not authorized"
    end
  end

  def authorize_sysadmin
    user = User.find_by(id: session[:user_id])
    group = user.group.name
    unless group == "sysadmin"
      redirect_to root_url, alert: "Not authorized"
    end
  end
end
