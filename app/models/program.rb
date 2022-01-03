class Program < ActiveRecord::Base
  has_many :courses
  has_many :pkgs, through: :courses

  # :instructors <= :programs_instructors => :programs
  has_many :programs_instructors
  has_many :instructors, through: :programs_instructors

  before_destroy :is_destroyable?

  def is_destroyable?
    courses.first.nil? and instructors.first.nil?
  end
end
