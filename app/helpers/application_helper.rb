module ApplicationHelper
  def current_user
    if session[:user_id]
      User.find_by(id: session[:user_id])
    else
      nil
    end
  end
  
  def current_user_fullname
    if session[:user_id]
      user = User.find_by(id: session[:user_id])
      if user
        user.fullname
      else
        nil
      end
    else
      nil
    end
  end
end
