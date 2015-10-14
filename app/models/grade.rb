class Grade < ActiveRecord::Base
  belongs_to :instructor
  belongs_to :students_record
  belongs_to :exam
  belongs_to :student

  validates_uniqueness_of :exam, scope: :students_record

  def ordered_exam_grade
    # convert exam_grade to array, assign non-existent value with '-'
    exam.grade_component.items.each.with_index.map do |e,idx|
      OpenStruct.new(id: idx, value: exam_grade[idx.to_s] || '-')
    end
  end

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
    where(:exam => exam)
  }

  scope :with_instructor, ->(instructor) {
    where(:instructor => instructor)
  }
end
