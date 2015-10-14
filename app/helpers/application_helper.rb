module ApplicationHelper

  def active_tab_class(*paths)  
    active = false  
    paths.each { |path| active ||= current_page?(path) }  
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

  # grade_component.structure
  def grade_component_as_table_heading structure
    out = {}
    visit_grade_component out, structure
    render_visited_grade_component(out)
  end

  protected
  def visit_grade_component out, structure, depth=0
    structure.each.with_index do |e,i|
      out[depth] ||= []
      if e.has_key? "members"
        out[depth][0] ||= []
        out[depth][0].push %{<th colspan="#{e['members'].size}">#{e['group']}</th>}
        visit_grade_component(out, e['members'], depth + 1)
      else
        out[depth][0] ||= []
        out[depth][0].push "<th>#{e['component']}</th>"
        out[depth][1] ||= []
        out[depth][1].push "<th>#{e['scale'] || 'no scale'}</th>"
      end
    end
  end

  def render_visited_grade_component inp
    heading_rows = inp.values.inject(0) {|m,o| m += o.size}

    inp.keys.each.with_index.sort {|a,b| a[0].to_i <=> b[0].to_i}.map do |k,i|
      inp[k].inject('') do |m,o|
        if i == 0
          m += %{<tr><th rowspan="#{heading_rows}">Nama</th>} + o.join("") +
                %{<th rowspan="#{heading_rows}">Total</th></tr>}
        else
          m += "<tr>" + o.join("") + "</tr>"
        end
        m
      end
    end.join("\n")
  end
end
