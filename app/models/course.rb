class Course < ActiveRecord::Base
  has_many :pkgs
  has_one :pkg_grade_component
end
