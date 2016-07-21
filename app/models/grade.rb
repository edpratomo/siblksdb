class Grade < ActiveRecord::Base
  # belongs_to :instructor
  belongs_to :students_record
  belongs_to :student

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

  scope :with_instructor, ->(instructor) {
    where(:instructor_id => instructor)
  }

  scope :with_pkg, ->(pkg) {
    where(:students_record => StudentsRecord.where(pkg: pkg))
  }

  scope :with_student_status, ->(status) {
    where(:students_record => StudentsRecord.where(status: status))
  }
end
