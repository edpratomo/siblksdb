class Grade < ActiveRecord::Base
  belongs_to :instructor
  belongs_to :students_record
  belongs_to :student
  belongs_to :component

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
      joins(:students_record).reorder("students_records.#{$1} #{$2}")
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

  def self.options_for_sorted_by
    [
      ['Tanggal mulai (baru -> lama)', 'started_on_desc'],
      ['Tanggal mulai (lama -> baru)', 'started_on_asc'],
    ]
  end

  def self.options_for_instructor
    select(:instructor_id).distinct.map {|e| [ Instructor.find(e.instructor_id).nick, e.instructor_id] }.sort_by {|e| e[0] }
  end

  def self.options_for_pkg
    joins(:students_record).select('students_records.pkg_id AS pkg_id').distinct.map {|e|
      pkg = Pkg.find(e.pkg_id)
      [ "#{pkg.pkg} Level #{pkg.level}", e.pkg_id ]
    }.sort_by {|e| e[0] }
  end
end
