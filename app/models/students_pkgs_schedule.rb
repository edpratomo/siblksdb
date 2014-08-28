class StudentsPkgsSchedule < ActiveRecord::Base
  belongs_to :user, :foreign_key => 'modified_by'
  
  #before_create do # not working
  #  self.modified_by = User.find_by(id: session[:user_id])
  #end

  # students_pkgs<= students_pkgs_schedules => pkgs_schedules
  belongs_to :students_pkg
  belongs_to :pkgs_schedule
end
