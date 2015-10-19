class RepeatableGrade < ActiveRecord::Base
  belongs_to :students_record
  belongs_to :grade
  belongs_to :student
end

class TheoryGrade < RepeatableGrade
end

class ExamGrade < RepeatableGrade
  belongs_to :exam

  validates_uniqueness_of :exam, scope: :students_record

  def ordered_by_grade_components
    # convert exam_grade to array, assign non-existent value with '-'
    exam.grade_component.items.each.with_index.map do |e,idx|
      OpenStruct.new(id: idx, value: exam_grade[idx.to_s] || '-')
    end
  end

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
