class AddStudentColumnToGrade < ActiveRecord::Migration
  def up
    execute <<-SQL
ALTER TABLE grades ADD COLUMN student_id INTEGER NOT NULL REFERENCES students(id);

CREATE OR REPLACE FUNCTION cache_student()
  RETURNS TRIGGER AS $body$
DECLARE
  student INTEGER;
BEGIN
  student := (SELECT student_id FROM students_records WHERE id = NEW.students_record_id);
  IF (student IS NULL) THEN
    RAISE EXCEPTION '[CACHE_STUDENT] - student not found';
    RETURN NULL;
  ELSE
    NEW.student_id := student;
    RETURN NEW;
  END IF;
END;
$body$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_student_cache()
  RETURNS TRIGGER AS $body$
BEGIN
  UPDATE grades SET student_id = NEW.student_id WHERE students_record_id = OLD.id;
  RETURN NEW;
END;
$body$
LANGUAGE plpgsql;

CREATE TRIGGER grades_cache_student
 BEFORE INSERT ON grades
  FOR EACH ROW EXECUTE PROCEDURE cache_student()
;

CREATE TRIGGER grades_update_student_cache
 AFTER UPDATE OF student_id ON students_records
  FOR EACH ROW EXECUTE PROCEDURE update_student_cache()
;
SQL
  end

  def down
    execute <<-SQL
DROP TRIGGER IF EXISTS grades_cache_student ON grades;
DROP TRIGGER IF EXISTS grades_update_student_cache ON students_records;
ALTER TABLE grades DROP COLUMN student_id;
SQL
  end
end
