class Grade < ActiveRecord::Base
  belongs_to :instructor
  belongs_to :students_record
  belongs_to :exam

  def ordered_grade components
    orders = components.inject({}) {|m,o| m[o.id.to_s] = o.sequence; m}
    if grade.empty?
      components.map {|e| OpenStruct.new(id: e.id.to_s, value: '-')}
    else
      # fill in gaps
      grade_dup = components.inject(grade) {|m,o| m[o.id.to_s] ||= '-'; m}
      grade_dup.keys.sort {|a,b| orders[a] <=> orders[b]}.map do |k|
        #grade_dup[k]
        OpenStruct.new(id: k, value: grade_dup[k])
      end
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
