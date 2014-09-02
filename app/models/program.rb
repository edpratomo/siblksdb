class Program < ActiveRecord::Base
  has_many :pkgs

  # :instructors <= :programs_instructors => :programs
  has_many :programs_instructors
  has_many :instructors, through: :programs_instructors
end
