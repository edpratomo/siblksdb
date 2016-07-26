class StudentsRecord < ActiveRecord::Base
  # :students <= :students_records => :pkgs
  belongs_to :student
  belongs_to :pkg

  has_one :grade

  validates_presence_of :pkg

  validate :finished_on_cant_be_blank
#  validate :finished_on_must_be_after_started_on
#  validate :started_on_for_level_above_1
  validate :started_on_cant_be_before_registration

  def finished_on_cant_be_blank
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
end
