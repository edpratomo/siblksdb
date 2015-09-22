class AddGradeSum < ActiveRecord::Migration
  def up
    execute <<-SQL
ALTER TABLE grades ALTER COLUMN students_record_id SET NOT NULL;
ALTER TABLE grades ALTER COLUMN instructor_id SET NOT NULL;
ALTER TABLE grades ADD COLUMN grade_sum FLOAT;

CREATE OR REPLACE FUNCTION compute_sum()
  RETURNS TRIGGER AS $body$
DECLARE
  grade_sum FLOAT;
BEGIN
  grade_sum := (SELECT SUM(cvalues) from (SELECT ((svals(NEW.grade))::FLOAT) AS cvalues) AS x);
  IF (grade_sum IS NOT NULL) THEN
    NEW.grade_sum := grade_sum;
  END IF;
  RETURN NEW;
END;
$body$
LANGUAGE plpgsql;

CREATE TRIGGER grades_compute_sum
 BEFORE UPDATE OF grade ON grades
  FOR EACH ROW EXECUTE PROCEDURE compute_sum()
;
SQL
  end

  def down
    execute <<-SQL
DROP TRIGGER IF EXISTS grades_compute_sum ON grades;
ALTER TABLE grades DROP COLUMN grade_sum;
SQL
  end
end
