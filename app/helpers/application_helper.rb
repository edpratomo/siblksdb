module ApplicationHelper

  def active_tab_class(*paths)  
    active = false  
    paths.each { |path| active ||= current_page?(path) }  
    #paths.each { |path| active ||= (current_page == path) }
    active ? 'active' : ''  
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
