class GradeComponent < ActiveRecord::Base
end

class ExamGradeComponent < GradeComponent
  has_many :exams, foreign_key: 'grade_component_id' # one ExamGradeComponent can be used by many exams
end

class PkgGradeComponent < GradeComponent
  belongs_to :course
end
