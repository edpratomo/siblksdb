class StudentsQualification < ActiveRecord::Base
  # :students <= :students_qualifications => :pkgs
  belongs_to :student
  belongs_to :pkg
end
