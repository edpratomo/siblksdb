class AddHeadInstructor < ActiveRecord::Migration
  def up
    execute <<-SQL
ALTER TABLE programs ADD COLUMN head_instructor_id INTEGER REFERENCES instructors(id);
SQL
  end

  def down
    execute <<-SQL
ALTER TABLE programs DROP COLUMN head_instructor;
SQL
  end
end
