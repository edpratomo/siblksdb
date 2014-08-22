CREATE TABLE programs (
  id SERIAL PRIMARY KEY,
  program TEXT NOT NULL UNIQUE,
  capacity INTEGER NOT NULL
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
  hashed_pass TEXT NOT NULL,
  email TEXT
);
  
CREATE TYPE sex_type AS ENUM ('female', 'male');
CREATE TYPE day_type AS ENUM ('mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun');
CREATE TYPE qualification_source AS ENUM ('course test', 'placement test');

CREATE TABLE students (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  birthplace TEXT,
  birthday TIMESTAMP,
  sex TEXT NOT NULL CHECK (sex IN ('female','male')),
  phone TEXT,
  note  TEXT,
  created_at TIMESTAMP NOT NULL DEFAULT clock_timestamp(),
  modified_at TIMESTAMP NOT NULL DEFAULT clock_timestamp(),
  modified_by INTEGER REFERENCES users(id)
);

CREATE INDEX students_name ON students(name);

CREATE TABLE students_pkgs (
  id SERIAL PRIMARY KEY,
  student_id INTEGER REFERENCES students(id),
  pkg_id INTEGER REFERENCES pkgs(id),
  created_at TIMESTAMP NOT NULL DEFAULT clock_timestamp(),
  modified_at TIMESTAMP NOT NULL DEFAULT clock_timestamp(),
  modified_by INTEGER REFERENCES users(id)
);

CREATE TABLE students_pkgs_schedules (
  id SERIAL PRIMARY KEY,
  student_pkg_id INTEGER REFERENCES students_pkgs(id),
  schedule_id INTEGER REFERENCES schedules(id),
  day TEXT NOT NULL CHECK (day IN ('mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun')),
  created_at TIMESTAMP NOT NULL DEFAULT clock_timestamp(),
  modified_at TIMESTAMP NOT NULL DEFAULT clock_timestamp(),
  modified_by INTEGER REFERENCES users(id)
);

CREATE TABLE students_qualifications (
  id SERIAL PRIMARY KEY,
  student_id INTEGER REFERENCES students(id),
  pkg_id INTEGER REFERENCES pkgs(id),
  acquired_from TEXT NOT NULL CHECK (acquired_from IN ('course test', 'placement test')),
  created_at TIMESTAMP NOT NULL DEFAULT clock_timestamp(),
  modified_at TIMESTAMP NOT NULL DEFAULT clock_timestamp(),
  modified_by INTEGER REFERENCES users(id)
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

-- CREATE TEMPORARY TABLE current_app_user(txid INTEGER DEFAULT txid_current(), username TEXT);
-- CREATE TEMPORARY TABLE current_user(username TEXT) ON COMMIT DROP;

CREATE OR REPLACE FUNCTION get_app_user() RETURNS TEXT AS $$
DECLARE
  cur_user TEXT;
BEGIN
  BEGIN
    cur_user := (SELECT username FROM current_app_user WHERE txid = txid_current());
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
    cur_user := (SELECT username FROM users WHERE id = NEW.modified_by);
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
    cur_user := (SELECT username FROM users WHERE id = NEW.modified_by);
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

-- triggers
CREATE TRIGGER students_if_modified 
 AFTER INSERT OR UPDATE OR DELETE ON students
  FOR EACH ROW EXECUTE PROCEDURE if_modified_func()
;
CREATE TRIGGER students_pkgs_if_modified 
 AFTER INSERT OR UPDATE OR DELETE ON students_pkgs
  FOR EACH ROW EXECUTE PROCEDURE if_modified_func()
;
CREATE TRIGGER students_pkgs_schedules_if_modified
 AFTER INSERT OR UPDATE OR DELETE ON students_pkgs_schedules
  FOR EACH ROW EXECUTE PROCEDURE if_modified_func()
;
CREATE TRIGGER students_qualifications_if_modified
 AFTER INSERT OR UPDATE OR DELETE ON students_qualifications
  FOR EACH ROW EXECUTE PROCEDURE if_modified_func()
;
CREATE TRIGGER students_update_timestamp 
 BEFORE UPDATE ON students
  FOR EACH ROW EXECUTE PROCEDURE update_timestamp()
;
CREATE TRIGGER students_pkgs_update_timestamp 
 BEFORE UPDATE ON students_pkgs
  FOR EACH ROW EXECUTE PROCEDURE update_timestamp()
;
CREATE TRIGGER students_pkgs_schedules_update_timestamp
 BEFORE UPDATE ON students_pkgs_schedules
  FOR EACH ROW EXECUTE PROCEDURE update_timestamp()
;
CREATE TRIGGER students_qualifications_update_timestamp
 BEFORE UPDATE ON students_qualifications
  FOR EACH ROW EXECUTE PROCEDURE update_timestamp()
;
