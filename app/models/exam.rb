class Exam < ActiveRecord::Base
  has_many :exams_exam_components
  has_many :components, through: :exams_exam_components, source: :exam_component
  has_many :grades, through: :exams_exam_components
end
