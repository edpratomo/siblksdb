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
  UPDATE grades SET grade = '' WHERE id = NEW.id;
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
  ELSIF (TG_TABLE_NAME = 'exam_components') THEN
    is_found := (SELECT COUNT(1) FROM exams ex 
                                      JOIN exams_exam_components eec ON ex.id = eec.exam_id
                                      JOIN exam_components components ON components.id = eec.exam_component_id
                 WHERE components.id = OLD.id AND ex.published_by IS NOT NULL);
    IF (is_found > 0) THEN
      RAISE WARNING '[check_exam_readonly] - exams is readonly';
      RETURN NULL;
    ELSE
      RETURN NEW;
    END IF;
  ELSIF (TG_TABLE_NAME = 'exams_exam_components') THEN
    is_found := (SELECT COUNT(1) FROM exams ex
                                      JOIN exams_exam_components eec ON ex.id = eec.exam_id    
                 WHERE eec.id = OLD.id AND ex.published_by IS NOT NULL);
    IF (is_found > 0) THEN
      RAISE WARNING '[check_exam_readonly] - exams is readonly';
      RETURN NULL;
    ELSE
      RETURN NEW;
    END IF;
  ELSIF (TG_TABLE_NAME = 'grade_weights') THEN
    is_found := (SELECT COUNT(1) FROM exams ex 
                                      JOIN exams_exam_components eec ON ex.id = eec.exam_id
                                      JOIN exam_components components ON components.id = eec.exam_component_id
                                      JOIN grade_weights gw ON gw.id = components.grade_weight_id
                 WHERE gw.id = OLD.id AND ex.published_by IS NOT NULL);
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
DROP TRIGGER IF EXISTS exam_components_check_readonly ON exam_components;
DROP TRIGGER IF EXISTS exams_exam_components_check_readonly ON exams_exam_components;
DROP TRIGGER IF EXISTS grade_weights_check_readonly ON grade_weights;
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
-- exams, exam_components, exams_exam_components, grade_weights
CREATE TRIGGER exams_check_readonly
 BEFORE INSERT OR UPDATE OR DELETE on exams
  FOR EACH ROW EXECUTE PROCEDURE check_exam_readonly()
;

CREATE TRIGGER exam_components_check_readonly
 BEFORE INSERT OR UPDATE OR DELETE on exam_components
  FOR EACH ROW EXECUTE PROCEDURE check_exam_readonly()
;

CREATE TRIGGER exams_exam_components_check_readonly
 BEFORE INSERT OR UPDATE OR DELETE on exams_exam_components
  FOR EACH ROW EXECUTE PROCEDURE check_exam_readonly()
;

CREATE TRIGGER grade_weights_check_readonly
 BEFORE INSERT OR UPDATE OR DELETE on grade_weights
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
