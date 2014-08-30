class PkgsSchedulesInstructor < ActiveRecord::Base
  belongs_to :instructor
  belongs_to :pkgs_schedule
  
  # :students <= :students_pkgs_schedules_instructors => :pkgs_schedules_instructors
  has_many :students_pkgs_schedules_instructors
  has_many :students, through: :students_pkgs_shedules_instructors
end
