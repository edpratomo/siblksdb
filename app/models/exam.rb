class Exam < ActiveRecord::Base
  belongs_to :exam_grade_component, foreign_key: 'grade_component_id'
  alias_method :grade_component, :exam_grade_component

  has_many :grades
  has_many :exam_grades

  belongs_to :pkg
end
