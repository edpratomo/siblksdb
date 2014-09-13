CREATE TABLE programs (
  id SERIAL PRIMARY KEY,
  program TEXT NOT NULL UNIQUE
);

CREATE TABLE pkgs (
  id SERIAL PRIMARY KEY,
  pkg TEXT NOT NULL,
  program_id INTEGER REFERENCES programs(id),
  level INTEGER NOT NULL
);

CREATE TABLE prereqs (
  id SERIAL PRIMARY KEY,
  pkg_id INTEGER REFERENCES pkgs(id),
  req_pkg_id INTEGER REFERENCES pkgs(id)
);

CREATE TABLE schedules (
  id SERIAL PRIMARY KEY,
  label TEXT NOT NULL UNIQUE,
  time_slot TEXT NOT NULL UNIQUE
);

CREATE TABLE groups (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE
);

CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  group_id INTEGER REFERENCES groups(id),
  username TEXT NOT NULL,
  fullname TEXT NOT NULL,
  password_digest TEXT NOT NULL,
  email TEXT
);
  
CREATE TYPE sex_type AS ENUM ('female', 'male');
CREATE TYPE day_type AS ENUM ('mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun');

CREATE TABLE students (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  birthplace TEXT,
  birthdate DATE,
  sex TEXT NOT NULL CHECK (sex IN ('female','male')),
  phone TEXT,
  note  TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT clock_timestamp(),
  modified_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT clock_timestamp(),
  modified_by TEXT
);

CREATE INDEX students_name ON students(name);

CREATE TABLE students_pkgs (
  id SERIAL PRIMARY KEY,
  student_id INTEGER REFERENCES students(id),
  pkg_id INTEGER REFERENCES pkgs(id),
  CONSTRAINT student_pkg_unique UNIQUE(student_id, pkg_id)
);

CREATE TABLE instructors (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  nick TEXT NOT NULL UNIQUE,
  capacity INTEGER NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT clock_timestamp(),
  modified_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT clock_timestamp(),
  modified_by TEXT
);

CREATE TABLE programs_instructors (
  id SERIAL PRIMARY KEY,
  program_id INTEGER REFERENCES programs(id),
  instructor_id INTEGER REFERENCES instructors(id)
);

CREATE TABLE instructors_schedules (
  id SERIAL PRIMARY KEY,
  schedule_id INTEGER REFERENCES schedules(id),
  instructor_id INTEGER REFERENCES instructors(id),
  day TEXT NOT NULL CHECK (day IN ('mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun')),
  avail_seat INTEGER NOT NULL,
  CONSTRAINT instructor_schedule_day_unique UNIQUE(schedule_id, instructor_id, day)
);

CREATE TABLE students_pkgs_instructors_schedules (
  id SERIAL PRIMARY KEY,
  students_pkg_id INTEGER REFERENCES students_pkgs(id),
  instructors_schedule_id INTEGER REFERENCES instructors_schedules(id),
  CONSTRAINT student_pkg_instructor_unique UNIQUE(students_pkg_id, instructors_schedule_id)
);

CREATE TABLE students_qualifications (
  id SERIAL PRIMARY KEY,
  student_id INTEGER REFERENCES students(id),
  pkg_id INTEGER REFERENCES pkgs(id),
  instructor_name TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT clock_timestamp(),
  modified_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT clock_timestamp(),
  modified_by TEXT
);

CREATE TABLE changes (
  id SERIAL PRIMARY KEY,
  table_name TEXT NOT NULL,
  action_tstamp timestamp WITH time zone NOT NULL DEFAULT clock_timestamp(),
  action TEXT NOT NULL CHECK (action IN ('I','D','U')),
  original_data TEXT,
  new_data TEXT,
  query TEXT,
  modified_by TEXT
);

-- exception list http://www.postgresql.org/docs/9.2/static/errcodes-appendix.html
-- CREATE TEMPORARY TABLE current_app_user(username TEXT) ON COMMIT DROP;
CREATE OR REPLACE FUNCTION get_app_user() RETURNS TEXT AS $$
DECLARE
  cur_user TEXT;
BEGIN
  BEGIN
    cur_user := (SELECT username FROM current_app_user);
  EXCEPTION WHEN undefined_table THEN
    cur_user := 'unknown user';
  END;
  RETURN cur_user;
END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION if_modified_func() 
  RETURNS TRIGGER AS $body$
DECLARE
  v_old_data TEXT;
  v_new_data TEXT;
  cur_user TEXT;
BEGIN
  IF (TG_OP = 'UPDATE') THEN
    v_old_data := ROW(OLD.*);
    v_new_data := ROW(NEW.*);
    BEGIN
      cur_user := NEW.modified_by;
    EXCEPTION WHEN undefined_column THEN
      cur_user := NULL;
    END;
    IF cur_user IS NULL THEN
      cur_user := get_app_user();
    END IF;
    INSERT INTO changes (table_name,action,original_data,new_data,query,modified_by) 
    VALUES (TG_TABLE_NAME::TEXT,substring(TG_OP,1,1),v_old_data,v_new_data, current_query(), cur_user);
    RETURN NEW;
  ELSIF (TG_OP = 'DELETE') THEN
    v_old_data := ROW(OLD.*);
    INSERT INTO changes (table_name,action,original_data,query,modified_by)
    VALUES (TG_TABLE_NAME::TEXT,substring(TG_OP,1,1),v_old_data, current_query(),get_app_user());
    RETURN OLD;
  ELSIF (TG_OP = 'INSERT') THEN
    v_new_data := ROW(NEW.*);
    BEGIN
      cur_user := NEW.modified_by;
    EXCEPTION WHEN undefined_column THEN
      cur_user := NULL;
    END;
    IF cur_user IS NULL THEN
      cur_user := get_app_user();
    END IF;
    INSERT INTO changes (table_name,action,new_data,query,modified_by)
    VALUES (TG_TABLE_NAME::TEXT,substring(TG_OP,1,1),v_new_data, current_query(), cur_user);
    RETURN NEW;
  ELSE
    RAISE WARNING '[IF_MODIFIED_FUNC] - Other action occurred: %, at %',TG_OP,now();
    RETURN NULL;
  END IF;
EXCEPTION
  WHEN data_exception THEN
    RAISE WARNING '[IF_MODIFIED_FUNC] - UDF ERROR [DATA EXCEPTION] - SQLSTATE: %, SQLERRM: %',SQLSTATE,SQLERRM;
    RETURN NULL;
  WHEN unique_violation THEN
    RAISE WARNING '[IF_MODIFIED_FUNC] - UDF ERROR [UNIQUE] - SQLSTATE: %, SQLERRM: %',SQLSTATE,SQLERRM;
    RETURN NULL;
  WHEN OTHERS THEN
    RAISE WARNING '[IF_MODIFIED_FUNC] - UDF ERROR [OTHER] - SQLSTATE: %, SQLERRM: %',SQLSTATE,SQLERRM;
    RETURN NULL;
END;
$body$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_timestamp()
  RETURNS TRIGGER AS $$
BEGIN
  NEW.modified_at = now(); 
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_userstamp()
  RETURNS TRIGGER AS $$
DECLARE
  cur_user TEXT;
BEGIN
  -- NEW.modified_at = now(); 
  cur_user = get_app_user();
  IF cur_user <> 'unknown user' THEN
    NEW.modified_by = cur_user;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION init_avail_seat()
  RETURNS TRIGGER AS $$
DECLARE
  v_capacity INTEGER;
BEGIN
  v_capacity := (SELECT capacity FROM instructors WHERE id = NEW.instructor_id);
  NEW.avail_seat = v_capacity;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION populate_instructors_schedules()
  RETURNS INTEGER AS $$
DECLARE
  instructors_rec  RECORD;
  sched_rec RECORD;
  dayv      TEXT;
  days      TEXT[] := ARRAY['mon', 'tue', 'wed', 'thu', 'fri', 'sat'];
BEGIN
  FOR instructors_rec IN SELECT id FROM instructors WHERE id > 1 AND id < 6 LOOP
    FOR sched_rec IN SELECT id, label FROM schedules LOOP
      FOREACH dayv IN ARRAY days LOOP
        IF NOT (dayv = 'wed' AND (sched_rec.label = 'Jam ke-4' OR sched_rec.label = 'Jam ke-5')) THEN
          INSERT INTO instructors_schedules (instructor_id, schedule_id, day) VALUES (instructors_rec.id, sched_rec.id, dayv);
        END IF;
      END LOOP;
    END LOOP;
  END LOOP;
  RETURN 1;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION initialize_instructors_schedules(v_instructor_id INTEGER)
  RETURNS INTEGER AS $$
DECLARE
  sched_rec RECORD;
  dayv      TEXT;
  days      TEXT[] := ARRAY['mon', 'tue', 'wed', 'thu', 'fri', 'sat'];
BEGIN
    FOR sched_rec IN SELECT id, label FROM schedules LOOP
      FOREACH dayv IN ARRAY days LOOP
        IF NOT (dayv = 'wed' AND (sched_rec.label = 'Jam ke-4' OR sched_rec.label = 'Jam ke-5')) THEN
          INSERT INTO instructors_schedules (instructor_id, schedule_id, day) VALUES (v_instructor_id, sched_rec.id, dayv);
        END IF;
      END LOOP;
    END LOOP;
  RETURN 1;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION populate_programs_instructors()
  RETURNS INTEGER AS $$
DECLARE
  instructors_rec  RECORD;
  programs_rec RECORD;
BEGIN
  FOR programs_rec IN SELECT id FROM programs WHERE id < 4 LOOP
    FOR instructors_rec IN SELECT id FROM instructors WHERE id > 1 AND id < 7 LOOP
      INSERT INTO programs_instructors(program_id, instructor_id) VALUES (programs_rec.id, instructors_rec.id);
    END LOOP;
  END LOOP;
  RETURN 1;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION update_avail_seat_by_cap()
  RETURNS TRIGGER AS $$
DECLARE
  v_delta   INTEGER;
BEGIN
  v_delta := NEW.capacity - OLD.capacity;
  
  IF (v_delta <> 0) THEN
    UPDATE instructors_schedules SET avail_seat = avail_seat + v_delta 
    WHERE instructor_id = OLD.id;
  END IF;
  RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_avail_seat() 
  RETURNS TRIGGER AS $body$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    UPDATE instructors_schedules SET avail_seat = avail_seat + 1 
    WHERE id = OLD.instructors_schedule_id;
    RETURN OLD;
  ELSEIF (TG_OP = 'INSERT') THEN
    UPDATE instructors_schedules SET avail_seat = avail_seat - 1 
    WHERE id = NEW.instructors_schedule_id;
    RETURN NEW;
  ELSE 
    RAISE WARNING '[UPDATE_AVAIL_SEAT] - Other action occurred: %, at %',TG_OP,now();
    RETURN NULL;
  END IF;
EXCEPTION
  WHEN data_exception THEN
    RAISE WARNING '[UPDATE_AVAIL_SEAT] - UDF ERROR [DATA EXCEPTION] - SQLSTATE: %, SQLERRM: %',SQLSTATE,SQLERRM;
    RETURN NULL;
  WHEN unique_violation THEN
    RAISE WARNING '[UPDATE_AVAIL_SEAT] - UDF ERROR [UNIQUE] - SQLSTATE: %, SQLERRM: %',SQLSTATE,SQLERRM;
    RETURN NULL;
  WHEN OTHERS THEN
    RAISE WARNING '[UPDATE_AVAIL_SEAT] - UDF ERROR [OTHER] - SQLSTATE: %, SQLERRM: %',SQLSTATE,SQLERRM;
    RETURN NULL;
END;
$body$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION check_instructors_program()
  RETURNS TRIGGER AS $body$
DECLARE
  is_found   INTEGER;
BEGIN
  is_found := (SELECT COUNT(1) FROM students_pkgs sp 
                                    JOIN pkgs ON sp.pkg_id = pkgs.id 
                                    JOIN programs_instructors prins ON prins.program_id = pkgs.program_id
                                    JOIN instructors ins ON ins.id = prins.instructor_id
                                    JOIN instructors_schedules insch ON insch.instructor_id = ins.id
               WHERE sp.id = NEW.students_pkg_id AND insch.id = NEW.instructors_schedule_id);
  IF NOT (is_found = 1) THEN
    RAISE EXCEPTION '[CHECK_INSTRUCTORS_PROGRAM] - instructor does not match program';
    RETURN NULL;
  ELSE
    RETURN NEW;
  END IF;
END;
$body$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION check_unique_schedule()
  RETURNS TRIGGER AS $body$
DECLARE
  is_found    INTEGER;
  v_student_id  INTEGER;
  v_schedule_id INTEGER;
  v_day         TEXT;
BEGIN
  v_student_id := (SELECT std.id FROM students std JOIN students_pkgs sp ON std.id = sp.student_id WHERE sp.id = NEW.students_pkg_id);
  v_schedule_id := (SELECT schedule_id FROM instructors_schedules WHERE id = NEW.instructors_schedule_id);
  v_day := (SELECT "day" FROM instructors_schedules WHERE id = NEW.instructors_schedule_id);

  is_found := (SELECT COUNT(1) FROM students_pkgs_instructors_schedules spis
                                    JOIN instructors_schedules insched ON spis.instructors_schedule_id = insched.id 
                                    JOIN students_pkgs sp ON sp.id = spis.students_pkg_id 
               WHERE sp.student_id = v_student_id AND 
                     insched.schedule_id = v_schedule_id AND
                     insched.day = v_day);
  IF (is_found >= 1) THEN
    RAISE EXCEPTION '[CHECK_UNIQUE_SCHEDULE] - already exists';
    RETURN NULL;
  ELSE
    RETURN NEW;
  END IF;
END;
$body$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION check_avail_seat()
  RETURNS TRIGGER AS $body$
DECLARE
  v_avail_seat  INTEGER;
BEGIN
  v_avail_seat := (SELECT avail_seat FROM instructors_schedules WHERE id = NEW.instructors_schedule_id);
  IF (v_avail_seat < 1) THEN
    RAISE EXCEPTION '[CHECK_AVAIL_SEAT] - seat not available';
    RETURN NULL;
  ELSE
    RETURN NEW;
  END IF;
END;
$body$
LANGUAGE plpgsql;

-- triggers
-- audit log
CREATE TRIGGER students_if_modified 
 AFTER INSERT OR UPDATE OR DELETE ON students
  FOR EACH ROW EXECUTE PROCEDURE if_modified_func()
;
CREATE TRIGGER students_qualifications_if_modified
 AFTER INSERT OR UPDATE OR DELETE ON students_qualifications
  FOR EACH ROW EXECUTE PROCEDURE if_modified_func()
;
CREATE TRIGGER instructors_if_modified
 AFTER INSERT OR UPDATE OR DELETE ON instructors
  FOR EACH ROW EXECUTE PROCEDURE if_modified_func()
;
CREATE TRIGGER students_pkgs_if_modified
 AFTER INSERT OR UPDATE OR DELETE ON students_pkgs
  FOR EACH ROW EXECUTE PROCEDURE if_modified_func()
;
CREATE TRIGGER programs_instructors_if_modified
 AFTER INSERT OR UPDATE OR DELETE ON programs_instructors
  FOR EACH ROW EXECUTE PROCEDURE if_modified_func()
;
CREATE TRIGGER instructors_schedules_if_modified
 AFTER INSERT OR UPDATE OR DELETE ON instructors_schedules
  FOR EACH ROW EXECUTE PROCEDURE if_modified_func()
;
CREATE TRIGGER students_pkgs_instructors_schedules_if_modified
 AFTER INSERT OR UPDATE OR DELETE ON students_pkgs_instructors_schedules
  FOR EACH ROW EXECUTE PROCEDURE if_modified_func()
;
-- timestamp
CREATE TRIGGER students_update_timestamp 
 BEFORE UPDATE ON students
  FOR EACH ROW EXECUTE PROCEDURE update_timestamp()
;
CREATE TRIGGER students_qualifications_update_timestamp 
 BEFORE UPDATE ON students_qualifications
  FOR EACH ROW EXECUTE PROCEDURE update_timestamp()
;
CREATE TRIGGER instructors_update_timestamp 
 BEFORE UPDATE ON instructors
  FOR EACH ROW EXECUTE PROCEDURE update_timestamp()
;
-- userstamp
CREATE TRIGGER students_update_userstamp 
 BEFORE INSERT OR UPDATE ON students
  FOR EACH ROW EXECUTE PROCEDURE update_userstamp()
;
CREATE TRIGGER students_qualifications_update_userstamp
 BEFORE INSERT OR UPDATE ON students_qualifications
  FOR EACH ROW EXECUTE PROCEDURE update_userstamp()
;
CREATE TRIGGER instructors_update_userstamp
 BEFORE INSERT OR UPDATE ON instructors
  FOR EACH ROW EXECUTE PROCEDURE update_userstamp()
;
-- initialize available seat based on instructor's seat capacity
CREATE TRIGGER instructors_schedules_init_avail_seat
 BEFORE INSERT ON instructors_schedules
  FOR EACH ROW EXECUTE PROCEDURE init_avail_seat();
;
-- capacity upgrades will update available seat
CREATE TRIGGER instructors_update_avail_seat_by_cap
 AFTER UPDATE ON instructors
  FOR EACH ROW EXECUTE PROCEDURE update_avail_seat_by_cap()
;
-- a schedule taken will decrease available seat
-- a schedule released will increase available seat
CREATE TRIGGER students_pkgs_instructors_schedules_update_avail_seat
 AFTER INSERT OR DELETE ON students_pkgs_instructors_schedules
  FOR EACH ROW EXECUTE PROCEDURE update_avail_seat()
;
-- check if a chosen instructor has the right program
CREATE TRIGGER students_pkgs_instructors_schedules_check_instructors_program
 BEFORE INSERT ON students_pkgs_instructors_schedules
  FOR EACH ROW EXECUTE PROCEDURE check_instructors_program()
;
-- check if the same student takes the same schedule/day more than once
CREATE TRIGGER students_pkgs_instructors_schedules_check_unique_schedule
 BEFORE INSERT ON students_pkgs_instructors_schedules
  FOR EACH ROW EXECUTE PROCEDURE check_unique_schedule()
;
-- check if seat is available
CREATE TRIGGER students_pkgs_instructors_schedules_check_avail_seat
 BEFORE INSERT ON students_pkgs_instructors_schedules
  FOR EACH ROW EXECUTE PROCEDURE check_avail_seat()
;
