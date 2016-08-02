class AddStudentStatus < ActiveRecord::Migration
  def up
    execute <<-SQL
ALTER TABLE students ADD COLUMN employment TEXT NOT NULL DEFAULT 'belum bekerja';
SQL
  end

  def down
    execute <<-SQL
ALTER TABLE students DROP COLUMN employment;
SQL
  end
end
