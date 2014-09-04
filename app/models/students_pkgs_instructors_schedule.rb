class StudentsPkgsInstructorsSchedule < ActiveRecord::Base
  # :students_pkgs <= :students_pkgs_instructors_schedules => :instructors_schedules
  belongs_to :students_pkg
  belongs_to :instructors_schedule
end
