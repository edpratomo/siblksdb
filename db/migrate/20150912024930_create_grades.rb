class CreateGrades < ActiveRecord::Migration
  def up
    files = %w(grade_sheets.sql trigger_grade_sheets.sql)
    files.each do |fn|
      execute File.read(File.join(Rails.root, "db", fn))
    end
  end

  def down
    execute <<-SQL
DROP TABLE IF EXISTS grades;
DROP TABLE IF EXISTS exams_exam_components;
DROP TABLE IF EXISTS exam_components;
DROP TABLE IF EXISTS grade_weights;
DROP TABLE IF EXISTS exams;
SQL
  end
end
