class PkgsSchedule < ActiveRecord::Base
  # pkgs <= pkgs_schedules => schedules
  belongs_to :pkg
  belongs_to :schedule

  # :instructors <= :pkgs_schedules_instructors => :pkgs_schedules
  has_many :pkgs_schedules_instructors
  has_many :instructors, through: :pkgs_schedules_instructors
end
