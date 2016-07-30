module GradesHelper
  def grade_group val_s
    return "" unless val_s =~ /^\d+$/
    val = val_s.to_i
    if val.between?(90, 100)
      "A"
    elsif val.between?(75, 89)
      "B"
    elsif val.between?(60, 74)
      "C"
    elsif val.between?(50, 59)
      "D"
    else
      ""
    end
  end
end

if $0 == __FILE__
  include GradesHelper
  
  puts grade_group "100 / 80"
  puts grade_group "89"
end
