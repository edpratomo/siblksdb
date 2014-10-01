class AddOnDeleteCascadeToStudentsPkgsInstructorsSchedules < ActiveRecord::Migration
  def change
    execute <<-SQL
ALTER TABLE students_pkgs_instructors_schedules DROP CONSTRAINT students_pkgs_instructors_schedules_students_pkg_id_fkey,
ADD CONSTRAINT students_pkgs_instructors_schedules_students_pkg_id_fkey FOREIGN KEY(students_pkg_id) REFERENCES 
students_pkgs(id) ON DELETE CASCADE;
SQL
  end
end
