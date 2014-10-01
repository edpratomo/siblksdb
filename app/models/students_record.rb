class StudentsRecord < ActiveRecord::Base
  include TransactionHelper

  # :students <= :students_records => :pkgs
  belongs_to :student
  belongs_to :pkg

  validate :finished_on_cant_be_blank

  def finished_on_cant_be_blank
    if self.finished_on.blank? and self.finished_on_changed?
      errors.add(:finished_on, "tidak dapat dihapus setelah diset")
      return false
    end
  end
end
