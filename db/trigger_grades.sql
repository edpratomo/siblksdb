
-- maintains student_id cache in grades table:
-- cache_student: create student_id on insert
-- update_student_cache: adjust student_id on students_records change

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

DROP TRIGGER IF EXISTS grades_cache_student ON grades;
DROP TRIGGER IF EXISTS grades_update_student_cache ON students_records;
DROP TRIGGER IF EXISTS grades_if_modified ON grades;
DROP TRIGGER IF EXISTS components_if_modified ON components;

CREATE TRIGGER grades_cache_student
 BEFORE INSERT ON grades
  FOR EACH ROW EXECUTE PROCEDURE cache_student()
;

CREATE TRIGGER grades_update_student_cache
 AFTER UPDATE OF student_id ON students_records
  FOR EACH ROW EXECUTE PROCEDURE update_student_cache()
;

-- timestamp triggers
CREATE TRIGGER grades_if_modified
 AFTER INSERT OR UPDATE OR DELETE ON grades
  FOR EACH ROW EXECUTE PROCEDURE if_modified_func()
;

CREATE TRIGGER components_if_modified
 AFTER INSERT OR UPDATE OR DELETE ON components
  FOR EACH ROW EXECUTE PROCEDURE if_modified_func()
;
