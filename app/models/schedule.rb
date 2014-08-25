class Schedule < ActiveRecord::Base
  has_many :pkgs_schedules
  has_many :pkgs, through: :pkgs_schedules
end
