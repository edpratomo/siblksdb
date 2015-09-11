class Grade < ActiveRecord::Base
  belongs_to :instructor
  belongs_to :students_record

  belongs_to :exams_exam_component
  belongs_to :exam_component, class_name: "ExamsExamComponent", foreign_key: "exams_exam_component_id"

  delegate :exam, :to => :exams_exam_component, :allow_nil => true

  # filter list
  filterrific(
    default_filter_params: { sorted_by: 'id_asc', with_exam: 0 },
    available_filters: [
      :sorted_by,
      :with_exam,
      :with_instructor
    ]
  )

  scope :sorted_by, ->(column_order) { 
    if Regexp.new('^(.+)_(asc|desc)$', Regexp::IGNORECASE).match(column_order)
      reorder("#{$1} #{$2}")
    end
  }

  scope :with_exam, ->(exam) {
    where(:exam_component => ExamsExamComponent.where(exam: exam))
  }

  scope :with_instructor, ->(instructor_id) {
    where(:instructor_id => instructor_id)
  }
end
