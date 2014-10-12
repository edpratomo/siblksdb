class AlterStatusDefaultOnStudentsRecords < ActiveRecord::Migration
  def change
    execute <<-SQL
ALTER TABLE students_records ALTER COLUMN status SET DEFAULT 'active'  
SQL
  end
end
