
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

CREATE TRIGGER grades_cache_student
 BEFORE INSERT ON grades
  FOR EACH ROW EXECUTE PROCEDURE cache_student()
;

CREATE TRIGGER grades_update_student_cache
 AFTER UPDATE OF student_id ON students_records
  FOR EACH ROW EXECUTE PROCEDURE update_student_cache()
;

-- prevent changes to exam and its grade_component if exam is published

CREATE OR REPLACE FUNCTION check_exam_published()
  RETURNS TRIGGER AS $body$
DECLARE
  publisher TEXT;
BEGIN
  publisher := (SELECT published_by FROM exams WHERE id = NEW.exam_id);
  IF (publisher IS NULL) THEN
    RAISE EXCEPTION '[CHECK_EXAM_PUBLISHED] - exam is not published yet';
    RETURN NULL;
  ELSE
    RETURN NEW;
  END IF;
END;
$body$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION clear_grade()
  RETURNS TRIGGER AS $body$
BEGIN
  UPDATE grades SET exam_grade = '' WHERE id = NEW.id;
  RETURN NEW;
END;
$body$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION check_exam_readonly()
  RETURNS TRIGGER AS $body$
DECLARE
  publisher TEXT;
  is_found  INTEGER;
BEGIN
  IF (TG_TABLE_NAME = 'exams') THEN
    publisher := (SELECT published_by FROM exams WHERE id = OLD.id);
    IF (publisher IS NULL) THEN
      RETURN NEW;
    ELSE
      RAISE WARNING '[check_exam_readonly] - exams is readonly';
      RETURN NULL;
    END IF;
  ELSIF (TG_TABLE_NAME = 'grade_components') THEN
    is_found := (SELECT COUNT(1) FROM exams WHERE grade_component_id = OLD.id 
                                              AND published_by IS NOT NULL);
    IF (is_found > 0) THEN
      RAISE WARNING '[check_exam_readonly] - exams is readonly';
      RETURN NULL;
    ELSE
      RETURN NEW;
    END IF;
  ELSE
    RETURN NEW;
  END IF;
END;
$body$
LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS grades_01_check_exam_published ON grades;
DROP TRIGGER IF EXISTS grades_clear_grade ON grades;
DROP TRIGGER IF EXISTS exams_check_readonly ON exams;
DROP TRIGGER IF EXISTS grade_components_check_readonly ON grade_components;
DROP TRIGGER IF EXISTS grades_if_modified ON grades;
DROP TRIGGER IF EXISTS exams_if_modified ON exams;

-- check if exam has been published before modifying grades
CREATE TRIGGER grades_01_check_exam_published
 BEFORE INSERT OR UPDATE ON grades
  FOR EACH ROW EXECUTE PROCEDURE check_exam_published()
;

CREATE TRIGGER grades_clear_grade
 AFTER UPDATE OF exam_id ON grades 
  FOR EACH ROW EXECUTE PROCEDURE clear_grade()
;

-- check if exams readonly on the following tables:
-- exams, grade_components
CREATE TRIGGER exams_check_readonly
 BEFORE INSERT OR UPDATE OR DELETE on exams
  FOR EACH ROW EXECUTE PROCEDURE check_exam_readonly()
;

CREATE TRIGGER grade_components_check_readonly
 BEFORE INSERT OR UPDATE OR DELETE on grade_components
  FOR EACH ROW EXECUTE PROCEDURE check_exam_readonly()
;

-- timestamp triggers
CREATE TRIGGER grades_if_modified
 AFTER INSERT OR UPDATE OR DELETE ON grades
  FOR EACH ROW EXECUTE PROCEDURE if_modified_func()
;

CREATE TRIGGER exams_if_modified
 AFTER INSERT OR UPDATE OR DELETE ON exams
  FOR EACH ROW EXECUTE PROCEDURE if_modified_func()
;

-- compute grade_sum
CREATE OR REPLACE FUNCTION compute_sum()
  RETURNS TRIGGER AS $body$
DECLARE
  grade_sum FLOAT;
BEGIN
  grade_sum := (SELECT SUM(cvalues) from (SELECT ((svals(NEW.exam_grade))::FLOAT) AS cvalues) AS x);
  IF (grade_sum IS NOT NULL) THEN
    NEW.grade_sum := grade_sum;
  END IF;
  RETURN NEW;
END;
$body$
LANGUAGE plpgsql;

CREATE TRIGGER grades_compute_sum
 BEFORE UPDATE OF exam_grade ON grades
  FOR EACH ROW EXECUTE PROCEDURE compute_sum()
;
