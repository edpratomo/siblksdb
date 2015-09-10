class Instructor < ActiveRecord::Base
  include TransactionHelper

  validates :name, presence: true
  validates :nick, presence: true
  
  # :instructors <= :programs_instructors => :programs
  has_many :programs_instructors
  has_many :programs, through: :programs_instructors

  # :instructors <= :instructors_schedules => :schedules
  has_many :instructors_schedules
  has_many :schedules, through: :instructors_schedules

  has_many :students_pkgs_instructors_schedules, through: :instructors_schedules
  has_many :students_pkgs,                       through: :students_pkgs_instructors_schedules
  has_many :students,                            through: :students_pkgs

  # link instructor to user
  has_one :users_instructor
  has_one :user, through: :users_instructor

  has_many :grades
end
