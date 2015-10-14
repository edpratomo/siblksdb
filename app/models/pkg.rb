class Pkg < ActiveRecord::Base
  validates_presence_of :pkg

  belongs_to :program
  belongs_to :course

  # :students <= :students_pkgs => :pkgs
  has_many :students_pkgs
  has_many :students, through: :students_pkgs

  has_many :exams
end
