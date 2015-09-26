class Program < ActiveRecord::Base
  has_many :pkgs

  # :instructors <= :programs_instructors => :programs
  has_many :programs_instructors
  has_many :instructors, through: :programs_instructors
  
  belongs_to :head_instructor, class_name: "Instructor", foreign_key: :head_instructor_id
end
