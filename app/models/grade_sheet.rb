class GradeSheet < ActiveRecord::Base
  belongs_to :instructor
  belongs_to :students_record

  belongs_to :exams_exam_component
  belongs_to :exam_component, class_name: "ExamsExamComponent", foreign_key: "exams_exam_component_id"

  delegate :exam, :to => :exams_exam_component, :allow_nil => true
end
