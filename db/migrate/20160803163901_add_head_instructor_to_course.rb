class AddHeadInstructorToCourse < ActiveRecord::Migration
  def up
    execute <<-SQL
ALTER TABLE programs DROP COLUMN head_instructor_id;
ALTER TABLE courses ADD COLUMN head_instructor_id INTEGER REFERENCES instructors(id);
SQL
  end

  def down
    execute <<-SQL
ALTER TABLE courses DROP COLUMN head_instructor_id;
SQL
  end
end
