class GradePoint < ActiveRecord::Base
  belongs_to :students_record
  belongs_to :practice, class_name: "Grade", foreign_key: :practice_id
end
