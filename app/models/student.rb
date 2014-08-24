class Student < ActiveRecord::Base
  belongs_to :user

  has_many :students_pkgs
  has_many :pkgs, through: :students_pkgs
end
