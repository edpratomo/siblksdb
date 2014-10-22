module ReportHelper
  def pkg_name pkg_str
    pkg_str.sub(/ -\s+\d+$/, '')
  end
  
  def level pkg_str
    pkg_str.split(" - ").last.strip
  end
end
