class Student < ActiveRecord::Base
  belongs_to :user, :foreign_key => 'modified_by'

  # :students <= :students_pkgs_schedules_instructors => :pkgs_schedules_instructors
  has_many :students_pkgs_schedules_instructors
  has_many :pkgs_schedules_instructors, through: :students_pkgs_schedules_instructors
end
