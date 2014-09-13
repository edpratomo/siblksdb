class StudentsPkg < ActiveRecord::Base
  belongs_to :user, :foreign_key => 'modified_by'
  
  # :students <= :students_pkgs => :pkgs
  # allows this: Student.first.pkgs
  belongs_to :student
  belongs_to :pkg

  has_many :students_pkgs_instructors_schedules
  has_many :instructors_schedules, through: :students_pkgs_instructors_schedules

  def save_schedules chosen_instructors_schedules, current_user
    transaction do
      ActiveRecord::Base.connection.execute('CREATE TEMPORARY TABLE current_app_user(username TEXT) ON COMMIT DROP')
      ActiveRecord::Base.connection.execute("INSERT INTO current_app_user VALUES('#{current_user}')")
      self.instructors_schedules = chosen_instructors_schedules
    end
  end
end
