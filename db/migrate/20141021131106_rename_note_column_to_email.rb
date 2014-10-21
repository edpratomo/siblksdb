class RenameNoteColumnToEmail < ActiveRecord::Migration
  def change
    execute <<-SQL
ALTER TABLE students RENAME COLUMN note TO email
SQL
  end
end
