class RepeatableGrade < ActiveRecord::Base
  belongs_to :students_record
  belongs_to :grade
  belongs_to :student
end

class TheoryGrade < RepeatableGrade
end

class ExamGrade < RepeatableGrade
  belongs_to :exam

  filterrific(
    available_filters: [
      :sorted_by,
      :with_exam,
      :with_instructor,
      :with_pkg
    ]
  )

  scope :sorted_by, ->(column_order) {
    if Regexp.new('^(.+)_(asc|desc)$', Regexp::IGNORECASE).match(column_order)
      reorder("#{$1} #{$2}")
    end
  }

  scope :with_exam, ->(exam) {
    where(:exam => exam)
  }

  scope :with_instructor, ->(instructor) {
    where(grade: Grade.where(:instructor => instructor))
  }
end
