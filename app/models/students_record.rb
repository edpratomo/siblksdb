class StudentsRecord < ActiveRecord::Base
  # :students <= :students_records => :pkgs
  belongs_to :student
  belongs_to :pkg

  has_one :grade

  validates_presence_of :pkg

  validate :finished_on_cant_be_removed
#  validate :finished_on_must_be_after_started_on
#  validate :started_on_for_level_above_1
  validate :started_on_cant_be_before_registration
  validate :cant_abandon_course_if_already_has_grade

  before_update :set_default_finished_on, :if => :need_to_set_finished_on?

  after_update :create_initial_empty_grade, :if => :need_to_initialize_grade?
  after_update :generate_cert_if_eligible, :if => :finished_a_course?

  # this has to be the last in after_update callback chain:
  after_update :delete_students_schedule, :if => :schedule_can_be_deleted?

  def set_default_finished_on
    self.finished_on = DateTime.now.in_time_zone.to_date
  end

  def delete_students_schedule
    student.pkgs.destroy(pkg)
    true
  end

  def create_initial_empty_grade
    students_pkg = StudentsPkg.find_by(pkg: pkg, student: student)
    instructor_ids = students_pkg.instructors_schedules.map {|e| e.instructor_id}.uniq
    if instructor_ids.size > 1
      #flash[:alert] = "Error: Lebih dari satu instruktur."
      return true
    else
      course = pkg.course
      component = Component.where(course: course).order(:created_at).last
      # create empty grade
      new_grade = Grade.new(students_record: self,
                            instructor_id: instructor_ids.first,
                            component: component)
      new_grade.save!
      self.grade = new_grade
    end
  end

  def generate_cert_if_eligible
    this_course = pkg.course
    student.eligible_for_certs(this_course) {|course, grades|
      cert = Cert.new(student: student, course: course)
      cert.grades << grades
      cert.save!
    }
  end

  def finished_on_cant_be_removed
    if self.finished_on.blank? and self.finished_on_changed?
      errors.add(:finished_on, "tidak dapat dihapus setelah diset")
      return false
    end
  end

  def finished_on_must_be_after_started_on
    unless self.finished_on.blank?
      unless self.finished_on > self.started_on
        errors.add(:finished_on, "hanya dapat diisi tanggal setelah tanggal mulai")
        return false
      end
    end
  end

  def started_on_for_level_above_1
    if self.pkg.level > 1
      prev_level = self.pkg.level - 1
      prev_record  = self.student.students_records.joins(:pkg).find_by(
                       status: :finished,
                       "pkgs.program_id" => self.pkg.program_id,
                       "pkgs.level" => prev_level
                     )
      unless prev_record
        errors.add(:started_on, "hanya dapat diisi jika sudah lulus level sebelumnya")
        return false
      end
      unless self.started_on > prev_record.finished_on
        errors.add(:started_on, "hanya dapat diisi tanggal setelah tanggal lulus level sebelumnya")
        return false
      end
    end
  end

  def started_on_cant_be_before_registration
    if self.started_on < self.student.registered_at
      errors.add(:started_on, "tidak dapat diisi tanggal sebelum tanggal pendaftaran")
      return false
    end
  end

  def cant_abandon_course_if_already_has_grade
    if grade and status_changed? and status == "abandoned"
            flash[:alert] = "Error: this student has taken the exam for this subject."

    end
  end

  def destroyable?
    if self.status == "active"
      sp = StudentsPkg.find_by(pkg: self.pkg, student: self.student)
      return true unless sp
      return true if sp.instructors_schedules.size == 0
    else
      false
    end
  end

  filterrific(
    available_filters: [
      :sorted_by,
      :with_instructor,
      :with_grade_instructor,
      :with_status,
      :with_pkg
    ]
  )

  scope :sorted_by, ->(column_order) {
    if Regexp.new('^(.+)_(asc|desc)$', Regexp::IGNORECASE).match(column_order)
      reorder("#{$1} #{$2}")
    end
  }

  scope :with_instructor, ->(instructor) {
    joins("JOIN students_pkgs sp ON students_records.student_id = sp.student_id AND students_records.pkg_id = sp.pkg_id").
    joins("JOIN students_pkgs_instructors_schedules spis ON sp.id = spis.students_pkg_id").
    joins("JOIN instructors_schedules isc ON spis.instructors_schedule_id = isc.id").
    where("isc.instructor_id" => instructor).uniq
  }
  
  scope :with_grade_instructor, ->(instructor) {
    joins(:grade).where("grades.instructor_id" => instructor)
  }

  scope :with_status, ->(status) {
    where(status: status)
  }

  scope :with_pkg, ->(pkg) {
    where(pkg: pkg)
  }

  def self.options_for_sorted_by
    [
      ['Tanggal mulai (baru -> lama)', 'started_on_desc'],
      ['Tanggal mulai (lama -> baru)', 'started_on_asc'],
    ]
  end

  private
  def schedule_can_be_deleted?
    status_changed? and status_was == "active"
  end

  def need_to_set_finished_on?
    # finished_on only displayed when setting status to values other than "active"
    status_changed? and status != "active" and finished_on.nil?
  end

  def need_to_initialize_grade?
    unless grade
      status_changed? and status_was == "active" and (status == "failed" or status == "finished")
    end
  end

  def finished_a_course?
    status_changed? and status_was == "active" and grade and grade.passed?
  end
end
