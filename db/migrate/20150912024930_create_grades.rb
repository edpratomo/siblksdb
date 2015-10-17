class CreateGrades < ActiveRecord::Migration
  def up
    files = %w(grade_sheets.sql trigger_grade_sheets.sql)
    files.each do |fn|
      execute File.read(File.join(Rails.root, "db", fn))
    end
  end

  def down
    execute <<-SQL
ALTER TABLE pkgs DROP COLUMN course_id;
DROP TABLE IF EXISTS repeatable_grades;
DROP TABLE IF EXISTS grades;
DROP TABLE IF EXISTS exams;
DROP TABLE IF EXISTS grade_components;
DROP TABLE IF EXISTS courses;
SQL
  end
end
