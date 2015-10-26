class Grade < ActiveRecord::Base
#  belongs_to :instructor
  belongs_to :students_record
  belongs_to :student

  # repeatable_grades.grade_id
  has_one :exam_grade, foreign_key: 'grade_id'
  has_one :theory_grade, foreign_key: 'grade_id'

  delegate :pkg, to: :students_record

  def ordered_anypkg_grade
    anypkg_grade_component = AnyPkgGradeComponent.first # there's only one
    anypkg_grade_component.items.each.with_index.map do |e,idx|
      OpenStruct.new(id: idx, value: anypkg_grade[idx.to_s] || '-')
    end
  end

  def options_for_exam_grade
    ExamGrade.where(students_record: students_record).inject({}) do |m,e|
      m[e.id.to_s] = "#{e.grade_sum || '?'} (#{e.exam.name}) - #{e.created_at.to_date}"
      m["selected"] = e.id.to_s if e.grade_id
      m
    end
  end

  # filter list
  filterrific(
    # default_filter_params: { sorted_by: 'id_asc', with_exam: 0 },
    available_filters: [
      :sorted_by,
      :with_instructor,
      :with_pkg
    ]
  )

  scope :sorted_by, ->(column_order) {
    if Regexp.new('^(.+)_(asc|desc)$', Regexp::IGNORECASE).match(column_order)
      reorder("#{$1} #{$2}")
    end
  }

  # scope :with_exam, ->(exam) {
  #  where(:exam => exam)
  #}

  # low level, because of belongs_to
  scope :with_instructor, ->(instructor) {
    joins("JOIN repeatable_grades rg ON rg.grade_id = grades.id").where("rg.instructor_id": instructor)
  }

  scope :with_pkg, ->(pkg) {
    where(:students_record => StudentsRecord.where(pkg: pkg, status: "active"))
  }
end
