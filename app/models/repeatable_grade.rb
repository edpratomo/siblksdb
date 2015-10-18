class RepeatableGrade < ActiveRecord::Base
  belongs_to :students_record
  belongs_to :grade
end

class TheoryGrade < RepeatableGrade
end

class ExamGrade < RepeatableGrade
  belongs_to :exam
end
