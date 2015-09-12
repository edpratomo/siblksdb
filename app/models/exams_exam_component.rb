class ExamsExamComponent < ActiveRecord::Base
  belongs_to :exam
  belongs_to :exam_component
  
  has_many :grades
end
