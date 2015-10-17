class RepatableGrade < ActiveRecord::Base
end

class TheoryGrade < RepeatableGrade
  belongs_to :grade
end

class ExamGrade < RepeatableGrade
  belongs_to :grade
end
