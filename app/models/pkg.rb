class Pkg < ActiveRecord::Base
  validates_presence_of :pkg

  belongs_to :program

  # :students <= :students_pkgs => :pkgs
  has_many :students_pkgs
  has_many :students, through: :students_pkgs

  has_many :exams

  belongs_to :course
  # add Pkg#grade_component:
  delegate :pkg_grade_component, :to => :course
  alias_method :grade_component, :pkg_grade_component
end
