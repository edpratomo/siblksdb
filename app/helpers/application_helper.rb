module ApplicationHelper

  def active_tab_class(*paths)  
    active = false  
    paths.each { |path| active ||= current_page?(path) }  
    active ? 'active' : ''  
  end  

  def is_collapsed(controller)
    if controller_name == controller
      "in"
    else
      ""
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

  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = (column == sort_column) ? "current #{sort_direction}" : nil
    direction = (column == sort_column && sort_direction == "asc") ? "desc" : "asc"
    link_to title, {:sort => column, :direction => direction}, {:class => css_class}
  end

end
