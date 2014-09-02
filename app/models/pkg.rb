class Pkg < ActiveRecord::Base
  belongs_to :program

  # :students <= :students_pkgs => :pkgs
  has_many :students_pkgs
  has_many :students, through: :students_pkgs
end
