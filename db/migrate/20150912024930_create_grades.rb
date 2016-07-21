class CreateGrades < ActiveRecord::Migration
  def up
    files = %w(grades.sql trigger_grades.sql)
    files.each do |fn|
      execute File.read(File.join(Rails.root, "db", fn))
    end
  end

  def down
    execute <<-SQL
ALTER TABLE pkgs DROP COLUMN course_id;
DROP TABLE IF EXISTS grades;
DROP TABLE IF EXISTS components;
DROP TABLE IF EXISTS courses;
SQL
  end
end
