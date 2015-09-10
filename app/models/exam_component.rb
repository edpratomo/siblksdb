class ExamComponent < ActiveRecord::Base
  has_many :exams_exam_component
  has_many :exams, through: :exams_exam_component

  belongs_to :grade_weight
end
