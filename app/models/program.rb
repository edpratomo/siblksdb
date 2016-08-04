class Program < ActiveRecord::Base
  has_many :courses
  has_many :pkgs, through: :courses

  # :instructors <= :programs_instructors => :programs
  has_many :programs_instructors
  has_many :instructors, through: :programs_instructors
end
