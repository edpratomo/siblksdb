class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :authorize
  
  protected
  def current_user
    if session[:user_id]
      User.find_by(id: session[:user_id])
    else
      nil
    end
  end
  
  def authorize
    unless User.find_by(id: session[:user_id])
      redirect_to login_url
    end
    if session[:expires_at] and session[:expires_at] < Time.current
      # sign out user
      session[:user_id] = nil
      redirect_to login_url
    end
  end

  def authorize_admin
    user = User.find_by(id: session[:user_id])
    group = user.group.name
    unless group == "admin" or group == "sysadmin"
      # redirect_to root_url, alert: "Not authorized"
      send(:render, :text => "You are not allowed to access this action.",
                    :status => :forbidden)
    end
  end

  def authorize_sysadmin
    user = User.find_by(id: session[:user_id])
    group = user.group.name
    unless group == "sysadmin"
      # redirect_to root_url, alert: "Not authorized"
      send(:render, :text => "You are not allowed to access this action.",
                    :status => :forbidden)
    end
  end

  # check if current user has been linked to instructor
  def authorize_instructor
    user = User.find_by(id: session[:user_id])
    unless user.instructor
      send(:render, :text => "You are not allowed to access this action, since you are not linked to an instructor.",
                    :status => :forbidden)
    end
  end
end
