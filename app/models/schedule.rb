class Schedule < ActiveRecord::Base
  # :instructors <= :instructors_schedules => :schedules
  has_many :instructors_schedules
  has_many :instructors, through: :instructors_schedules
end
