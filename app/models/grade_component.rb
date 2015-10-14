class GradeComponent < ActiveRecord::Base
  # parse structure before returned
  def structure
    json = read_attribute(:structure)
    if json.empty?
      []
    else
      JSON.parse(json)
    end
  end

  # returns terminal nodes in structure
  def items
    find_terminals structure
  end

  protected
  def find_terminals ary
    ary.inject([]) do |m,o|
      if o.has_key? "component"
        os = OpenStruct.new(name: o["component"])
        o.has_key?("scale") and os.scale = o["scale"]
        m.push os
      elsif o.has_key? "group"
        ret = find_terminals(o["members"]).flatten
        unless ret.empty?
          m.push *ret
        end
      end
      m
    end
  end
end

class ExamGradeComponent < GradeComponent
  has_many :exams, foreign_key: 'grade_component_id' # one ExamGradeComponent can be used by many exams
end

class PkgGradeComponent < GradeComponent
  belongs_to :course
end
