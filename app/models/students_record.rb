class StudentsRecord < ActiveRecord::Base
  include TransactionHelper

  # :students <= :students_records => :pkgs
  belongs_to :student
  belongs_to :pkg

  validates_presence_of :pkg
  # validates_uniqueness_of :pkg

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
end
