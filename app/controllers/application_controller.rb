class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :authorize
  after_action :store_location

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
      # caused AbstractController::DoubleRenderError:
      # redirect_to login_url
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

  def permission_denied
    flash[:error] = "Sorry, you are not allowed to access that page."
    # redirect_to root_url
    redirect_back_or_default(root_url)
  end

  # http://stackoverflow.com/questions/2139996/how-to-redirect-to-previous-page-in-ruby-on-rails
  def store_location
    return unless request.get?
    if (controller_name != "sessions" and
        controller_name != "password_resets" and
        controller_name != "users" and
        !request.xhr?) # don't store ajax calls
      session[:return_to] = request.fullpath
    end
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
  end
end
