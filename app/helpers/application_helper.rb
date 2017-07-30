module ApplicationHelper
  include RenderGradeComponent

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

  def current_user_role
    if session[:user_id]
      user = User.find_by(id: session[:user_id])
      user.role.name if user
    end
  end

  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = (column == sort_column) ? "current #{sort_direction}" : nil
    direction = (column == sort_column && sort_direction == "asc") ? "desc" : "asc"
    link_to title, {:sort => column, :direction => direction}, {:class => css_class}
  end

  def bootstrap_class_for flash_type
    {
      success: "alert-success",
      error: "alert-danger",
      alert: "alert-warning",
      notice: "alert-info"
    }[flash_type.to_sym] || flash_type.to_s
  end

  def flash_messages(opts = {})
    flash.each do |msg_type, message|
      concat(
        content_tag(:div, message, class: "alert #{bootstrap_class_for(msg_type)} fade in", role: "alert", style: "font-size:large") do
          concat content_tag(:button, 'x', class: "close", data: { dismiss: 'alert' })
          concat content_tag(:strong, msg_type.capitalize + ": ")
          concat message
        end
      )
    end
    nil
  end
end
