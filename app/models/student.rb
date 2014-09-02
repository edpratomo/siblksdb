class Student < ActiveRecord::Base
  belongs_to :user, :foreign_key => 'modified_by'

  # :students <= :students_qualifications => :pkgs
  has_many :students_qualifications
  has_many :qualifications, through: :students_qualifications, source: :pkg
  
  # :students <= :students_pkgs => :pkgs
  has_many :students_pkgs
  has_many :pkgs,           through: :students_pkgs
end
