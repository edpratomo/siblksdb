class AlterStatusConstraintOnStudentsRecords < ActiveRecord::Migration
  def change
    execute <<-SQL
ALTER TABLE students_records DROP CONSTRAINT IF EXISTS students_records_status_check;
ALTER TABLE students_records ADD CONSTRAINT students_records_status_check CHECK (status IN ('active','finished','failed'));
SQL
  end
end
