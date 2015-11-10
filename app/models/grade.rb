class Grade < ActiveRecord::Base
#  belongs_to :instructor
  belongs_to :students_record
  belongs_to :student

  # repeatable_grades.grade_id
  has_one :exam_grade, foreign_key: 'grade_id'
  has_one :theory_grade, foreign_key: 'grade_id'

  delegate :pkg, to: :students_record

  def result
    %w{finished failed}.find {|e| e == students_record.status }
  end

  # update status of students_record to 'finished' or 'failed', and remove associated schedule
  def set_result new_status, by_user
    if %w{finished failed}.member?(new_status)
      if students_record.status == "active"
        ActiveRecord::Base.transaction_user(by_user) do
          if pkg
            student.pkgs.destroy(pkg) # this student has finished a pkg
          end
          students_record.update(status: new_status, finished_on: DateTime.now.in_time_zone)
        end
      else
        students_record.update(status: new_status, finished_on: DateTime.now.in_time_zone)
      end
    end
  end

  def theory_grades
    TheoryGrade.where(students_record: students_record).order(:created_at)
  end

  def ordered_pkg_grade
    PkgGradeComponent.find_by(course: pkg.course).items.each.with_index.map do |e,idx|
      OpenStruct.new(id: idx, value: pkg_grade[idx.to_s] || '-')
    end
  end

  def ordered_anypkg_grade pkg
    anypkg_grade_component = AnyPkgGradeComponent.first # there's only one
    anypkg_grade_component.items.each.with_index.map do |e,idx|
      if e.lambda
        pkg_grades = e.lambda.call(pkg.course)
        pkg_grades.each.with_index.map do |pg,pidx|
          OpenStruct.new(id: "#{pidx}_pkg", value: pkg_grade[pidx.to_s] || '-')
        end
      else
        OpenStruct.new(id: idx, value: anypkg_grade[idx.to_s] || '-')
      end
    end.
    flatten
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
      :with_pkg,
      :with_student_status
    ]
  )

  scope :sorted_by, ->(column_order) {
    if Regexp.new('^(.+)_(asc|desc)$', Regexp::IGNORECASE).match(column_order)
      reorder("#{$1} #{$2}")
    end
  }

  # low level, because of belongs_to
  scope :with_instructor, ->(instructor) {
    joins("JOIN repeatable_grades rg ON rg.grade_id = grades.id").where("rg.instructor_id": instructor)
  }

  scope :with_pkg, ->(pkg) {
    where(:students_record => StudentsRecord.where(pkg: pkg))
  }

  scope :with_student_status, ->(status) {
    where(:students_record => StudentsRecord.where(status: status))
  }
end
