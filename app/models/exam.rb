class Exam < ActiveRecord::Base
  belongs_to :exam_grade_component, foreign_key: 'grade_component_id'
  has_many :grades

  belongs_to :pkg
end
