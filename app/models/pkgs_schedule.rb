class PkgsSchedule < ActiveRecord::Base
  # pkgs <= pkgs_schedules => schedules
  belongs_to :pkg
  belongs_to :schedule

  # many-to-many with :students_pkgs, via :students_pkgs_schedules
  has_many :students_pkgs_schedules
  has_many :students_pkgs, through: :students_pkgs_schedules
end
