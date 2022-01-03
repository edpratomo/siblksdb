class Instructor < ActiveRecord::Base
  validates :name, presence: true
  validates :nick, presence: true
  
  # :instructors <= :programs_instructors => :programs => :pkgs
  has_many :programs_instructors, dependent: :destroy
  has_many :programs, through: :programs_instructors
  has_many :pkgs, through: :programs

  # :instructors <= :instructors_schedules => :schedules
  has_many :instructors_schedules, dependent: :destroy
  has_many :schedules, through: :instructors_schedules

  has_many :students_pkgs_instructors_schedules, through: :instructors_schedules
  has_many :students_pkgs,                       through: :students_pkgs_instructors_schedules
  has_many :students,                            through: :students_pkgs

  has_many :grades
  has_many :courses, foreign_key: :head_instructor_id

  # link instructor to user
  has_one :users_instructor
  has_one :user, through: :users_instructor

  before_destroy :is_destroyable?

  def options_for_pkg
    pkgs.map {|e| [ "#{e.pkg} - Level #{e.level}", e.id ] }
  end

  def is_destroyable?
    # must not be linked to user
    # must not have grade
    # must not have student
    # must not have course (as head instructor)
    user.nil? and grades.first.nil? and students.first.nil? and courses.first.nil?
  end
end
