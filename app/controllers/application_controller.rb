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

  def page_key
    (controller_name + "_page").to_sym
  end

  def set_current_page
    if params[:page] then
      session[page_key] = params[:page]
    elsif session[page_key]
      params[:page] = session[page_key]
    end
  end
end
