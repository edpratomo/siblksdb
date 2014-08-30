class Instructor < ActiveRecord::Base
  belongs_to :user, :foreign_key => 'modified_by'

  has_many :pkgs_schedules_instructors
  has_many :pkgs_schedules, through: :pkgs_schedules_instructors
end
