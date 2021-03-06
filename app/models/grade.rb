class Grade < ActiveRecord::Base
  belongs_to :instructor
  belongs_to :students_record
  belongs_to :student
  belongs_to :component

  has_many :grades_certs

  delegate :pkg, to: :students_record

  before_save :update_avg, if: :score_changed?

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

  scope :with_final_level, ->() {
    final_levels = Pkg.final_level_by_course
     pkgs = final_levels.inject([]) do |m,o|
       m.push Pkg.find_by(course_id: o[0], level: o[1])
       m
     end
     joins("JOIN students_records sr ON sr.id = students_record_id").where("sr.pkg_id" => pkgs)
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

  def self.options_for_student_status
    [
      ['Lulus', 'finished'],
      ['Aktif', 'active'],
      ['Tidak lulus', 'failed']
    ]
  end

  def update_avg_public
    update_avg
  end

  def passed?
    avg_practice >= 60 and avg_theory >= 60
  end

  private
  def update_avg
    sigindexes = ApplicationController.helpers.get_significant_indexes(component.content)
    if sigindexes["P"] and not sigindexes["P"].empty?
      self.avg_practice = sigindexes["P"].map {|e| score[e].to_f}.reduce(0, :+) / sigindexes["P"].size.to_f
    end
    if sigindexes["T"] and not sigindexes["T"].empty?
      self.avg_theory = sigindexes["T"].map {|e| score[e].to_f}.reduce(0, :+) / sigindexes["T"].size.to_f
    end
  end
end
