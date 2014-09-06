class Instructor < ActiveRecord::Base
  belongs_to :user, :foreign_key => 'modified_by'

  # :instructors <= :programs_instructors => :programs
  has_many :programs_instructors
  has_many :programs, through: :programs_instructors

  # :instructors <= :instructors_schedules => :schedules
  has_many :instructors_schedules
  has_many :schedules, through: :instructors_schedules

  has_many :students_pkgs_instructors_schedules, through: :instructors_schedules
  has_many :students_pkgs,                       through: :students_pkgs_instructors_schedules
  has_many :students,                            through: :students_pkgs
end
