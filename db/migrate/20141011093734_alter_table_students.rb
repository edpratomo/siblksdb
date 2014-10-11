class AlterTableStudents < ActiveRecord::Migration
  def change
    execute <<-SQL
ALTER TABLE students ADD COLUMN religion TEXT;
ALTER TABLE students ADD COLUMN street_address TEXT;
ALTER TABLE students ADD COLUMN district TEXT;
ALTER TABLE students ADD COLUMN regency_city TEXT;
ALTER TABLE students ADD COLUMN province TEXT;

CREATE INDEX students_religion_sex ON students(religion, sex);
SQL
  end
end
