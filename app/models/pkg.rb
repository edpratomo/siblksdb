class Pkg < ActiveRecord::Base
  belongs_to :program

  has_many :students_pkgs
  has_many :students, through: :students_pkgs
end
