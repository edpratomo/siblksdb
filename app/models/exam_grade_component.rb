class ExamGradeComponent < GradeComponent
  has_many :exams, foreign_key: 'grade_component_id' # one ExamGradeComponent can be used by many exams
end
