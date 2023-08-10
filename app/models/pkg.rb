class Pkg < ActiveRecord::Base
  #validates_presence_of :pkg

  # belongs_to :program
  delegate :program, to: :course
  belongs_to :course

  # :students <= :students_pkgs => :pkgs
  has_many :students_pkgs
  has_many :students, through: :students_pkgs

  # replace the old pkg column
  def pkg
    course.name
  end

  def self.final_level_by_course
    where(enabled: true).group(:course_id).maximum(:level)
  end
end
