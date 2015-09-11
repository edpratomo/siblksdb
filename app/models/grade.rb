class Grade < ActiveRecord::Base
  belongs_to :instructor
  belongs_to :students_record
  belongs_to :exam

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
