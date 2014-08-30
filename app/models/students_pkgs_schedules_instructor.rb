class StudentsPkgsSchedulesInstructor < ActiveRecord::Base
  # :students <= :students_pkgs_schedules_instructors => :pkgs_schedules_instructors
  belongs_to :student
  belongs_to :pkgs_schedules_instructor
end
