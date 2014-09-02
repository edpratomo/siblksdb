class ProgramsInstructor < ActiveRecord::Base
  # :instructors <= :programs_instructors => :programs
  belongs_to :program
  belongs_to :instructor
end
