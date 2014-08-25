class StudentsPkg < ActiveRecord::Base
  belongs_to :user, :foreign_key => 'modified_by'
  
  # students <= students_pkgs => pkgs
  # allows this: Student.first.pkgs
  belongs_to :student
  belongs_to :pkg

  # many-to-many with :pkgs_schedules, via :students_pkgs_schedules
  has_many :students_pkgs_schedules
  has_many :pkgs_schedules, through: :students_pkgs_schedules
end
