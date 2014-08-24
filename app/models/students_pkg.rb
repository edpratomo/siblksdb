class StudentsPkg < ActiveRecord::Base
  # students <= students_pkgs => pkgs
  # allows this: Student.first.pkgs
  belongs_to :student
  belongs_to :pkg
end
