class StudentsRecord < ActiveRecord::Base
  include TransactionHelper

  # :students <= :students_records => :pkgs
  belongs_to :student
  belongs_to :pkg

  validates_presence_of :pkg
  # validates_uniqueness_of :pkg

  validate :finished_on_cant_be_blank
  validate :started_on_cant_be_before_registration
  
  def finished_on_cant_be_blank
    if self.finished_on.blank? and self.finished_on_changed?
      errors.add(:finished_on, "tidak dapat dihapus setelah diset")
      return false
    end
  end

  def started_on_cant_be_before_registration
    if self.started_on < self.student.registered_at
      errors.add(:started_on, "tidak dapat diisi tanggal sebelum tanggal pendaftaran")
      return false
    end
  end
end
