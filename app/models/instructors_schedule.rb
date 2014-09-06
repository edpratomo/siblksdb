class InstructorsSchedule < ActiveRecord::Base
  # :instructors <= :instructors_schedules => :schedules
  belongs_to :instructor
  belongs_to :schedule

  # :students_pkgs <= :students_pkgs_instructors_schedules => :instructors_schedules
  has_many :students_pkgs_instructors_schedules
  has_many :students_pkgs, through: :students_pkgs_instructors_schedules

  has_many :students,      through: :students_pkgs
end
