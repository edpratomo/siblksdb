class StudentsPkgsSchedule < ActiveRecord::Base
  # students_pkgs<= students_pkgs_schedules => pkgs_schedules
  belongs_to :students_pkg
  belongs_to :pkgs_schedule
end
