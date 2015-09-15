class Instructor < ActiveRecord::Base
  include TransactionHelper

  validates :name, presence: true
  validates :nick, presence: true
  
  # :instructors <= :programs_instructors => :programs => :pkgs
  has_many :programs_instructors
  has_many :programs, through: :programs_instructors
  has_many :pkgs, through: :programs

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

  def options_for_exam published=true
    if published
      Exam.joins(:pkg).where("pkgs.program_id" => programs).where.not('published_by' => nil).
        order("pkgs.program_id", "pkgs.level").
        map {|ex| [ "#{ex.pkg.pkg} - Level #{ex.pkg.level} (#{ex.name})", ex.id ] }
    else
      Exam.joins(:pkg).where("pkgs.program_id" => programs).
        order("pkgs.program_id", "pkgs.level").
        map {|ex| [ "#{ex.pkg.pkg} - Level #{ex.pkg.level} (#{ex.name})", ex.id ] }
    end
  end

  def options_for_pkg
    pkgs.map {|e| [ "#{e.pkg} - Level #{e.level}", e.id ] }
  end
end
