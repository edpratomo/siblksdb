class StudentsPkg < ActiveRecord::Base
  # :students <= :students_pkgs => :pkgs
  # allows this: Student.first.pkgs
  belongs_to :student
  belongs_to :pkg

  has_many :students_pkgs_instructors_schedules
  has_many :instructors_schedules, through: :students_pkgs_instructors_schedules
end
