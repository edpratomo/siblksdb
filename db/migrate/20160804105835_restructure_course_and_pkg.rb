class RestructureCourseAndPkg < ActiveRecord::Migration
  # move program_id column from pkgs to courses
  def up
    execute <<-SQL
ALTER TABLE courses ADD COLUMN program_id INTEGER REFERENCES programs(id);

WITH program_data AS (SELECT course_id, program_id FROM pkgs) 
UPDATE courses SET program_id = pd.program_id
FROM program_data pd
WHERE pd.course_id = id;

ALTER TABLE pkgs DROP COLUMN program_id;
SQL
  end

  def down
    execute <<-SQL
ALTER TABLE pkgs ADD COLUMN program_id INTEGER REFERENCES programs(id);

WITH program_data AS (SELECT id, program_id FROM courses)
UPDATE pkgs SET program_id = pd.program_id
FROM program_data pd
WHERE course_id = pd.id;

ALTER TABLE courses DROP COLUMN program_id;
SQL
  end
end
