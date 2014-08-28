class Student < ActiveRecord::Base
  belongs_to :user, :foreign_key => 'modified_by'

  has_many :students_pkgs
  has_many :pkgs, through: :students_pkgs

  accepts_nested_attributes_for :pkgs
end
