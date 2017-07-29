class InitSchema < ActiveRecord::Migration
  def change
    execute <<-SQL
--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


--
-- Name: pg_redispub; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_redispub WITH SCHEMA public;


--
-- Name: EXTENSION pg_redispub; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_redispub IS 'publish to redis';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET search_path = public, pg_catalog;

--
-- Name: day_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE day_type AS ENUM (
    'mon',
    'tue',
    'wed',
    'thu',
    'fri',
    'sat',
    'sun'
);


--
-- Name: sex_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE sex_type AS ENUM (
    'female',
    'male'
);


--
-- Name: cache_student(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cache_student() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


--
-- Name: check_avail_seat(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION check_avail_seat() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


--
-- Name: check_instructors_program(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION check_instructors_program() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  is_found   INTEGER;
BEGIN
  is_found := (SELECT COUNT(1) FROM students_pkgs sp 
                                    JOIN pkgs ON sp.pkg_id = pkgs.id 
                                    JOIN courses ON courses.id = pkgs.course_id
                                    JOIN programs_instructors prins ON prins.program_id = courses.program_id
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
$$;


--
-- Name: check_registered_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION check_registered_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  first_started_on TIMESTAMP;
BEGIN
  IF DATE(NEW.registered_at) > DATE(OLD.created_at) THEN
    RAISE EXCEPTION '[CHECK_REGISTERED_AT] - registration date can not be later than entry date';
    RETURN NULL;
  END IF;
  first_started_on := (SELECT MIN(started_on) FROM students_records WHERE student_id = OLD.id);
  IF first_started_on IS NOT NULL THEN
    IF DATE(first_started_on) < DATE(NEW.registered_at) THEN
      RAISE EXCEPTION '[CHECK_REGISTERED_AT] - first course date is earlier than registration date';
      RETURN NULL;
    END IF;
  END IF;
  RETURN NEW;
END;
$$;


--
-- Name: check_unique_schedule(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION check_unique_schedule() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


--
-- Name: get_app_user(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION get_app_user() RETURNS text
    LANGUAGE plpgsql
    AS $$
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
$$;


--
-- Name: if_avail_seat_change(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION if_avail_seat_change() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
DECLARE
  channel_suffix TEXT;
BEGIN
  channel_suffix := (SELECT SUBSTRING((SELECT current_catalog) FROM '_(.+)$'));
  PERFORM redispub('seat_' || channel_suffix, NEW.id::TEXT || '_' || NEW.avail_seat::TEXT);
  RETURN NEW;
END;
$_$;


--
-- Name: if_modified_func(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION if_modified_func() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


--
-- Name: init_avail_seat(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION init_avail_seat() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  v_capacity INTEGER;
BEGIN
  v_capacity := (SELECT capacity FROM instructors WHERE id = NEW.instructor_id);
  NEW.avail_seat = v_capacity;
  RETURN NEW;
END;
$$;


--
-- Name: initialize_instructors_schedules(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION initialize_instructors_schedules(v_instructor_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
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
$$;


--
-- Name: populate_instructors_schedules(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION populate_instructors_schedules() RETURNS integer
    LANGUAGE plpgsql
    AS $$
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
$$;


--
-- Name: populate_programs_instructors(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION populate_programs_instructors() RETURNS integer
    LANGUAGE plpgsql
    AS $$
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
$$;


--
-- Name: update_avail_seat(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION update_avail_seat() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


--
-- Name: update_avail_seat_by_cap(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION update_avail_seat_by_cap() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


--
-- Name: update_student_cache(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION update_student_cache() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  UPDATE grades SET student_id = NEW.student_id WHERE students_record_id = OLD.id;
  RETURN NEW;
END;
$$;


--
-- Name: update_timestamp(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION update_timestamp() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.modified_at = now(); 
  RETURN NEW;
END;
$$;


--
-- Name: update_userstamp(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION update_userstamp() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: changes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE changes (
    id integer NOT NULL,
    table_name text NOT NULL,
    action_tstamp timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    action text NOT NULL,
    original_data text,
    new_data text,
    query text,
    modified_by text,
    CONSTRAINT changes_action_check CHECK ((action = ANY (ARRAY['I'::text, 'D'::text, 'U'::text])))
);


--
-- Name: changes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE changes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: changes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE changes_id_seq OWNED BY changes.id;


--
-- Name: components; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE components (
    id integer NOT NULL,
    content text DEFAULT ''::text NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    modified_by text,
    course_id integer NOT NULL,
    modified_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL
);


--
-- Name: components_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE components_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: components_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE components_id_seq OWNED BY components.id;


--
-- Name: courses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE courses (
    id integer NOT NULL,
    name text NOT NULL,
    idn_prefix text DEFAULT ''::text NOT NULL,
    head_instructor_id integer,
    program_id integer
);


--
-- Name: courses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE courses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: courses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE courses_id_seq OWNED BY courses.id;


--
-- Name: districts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE districts (
    id integer NOT NULL,
    code character varying(7) NOT NULL,
    regency_city_code character varying(4) NOT NULL,
    name character varying(30) NOT NULL
);


--
-- Name: districts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE districts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: districts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE districts_id_seq OWNED BY districts.id;


--
-- Name: grades; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE grades (
    id integer NOT NULL,
    instructor_id integer NOT NULL,
    students_record_id integer NOT NULL,
    student_id integer,
    component_id integer,
    score hstore DEFAULT ''::hstore NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    modified_by text,
    avg_practice double precision DEFAULT 0 NOT NULL,
    avg_theory double precision DEFAULT 0 NOT NULL,
    modified_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL
);


--
-- Name: grades_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE grades_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: grades_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE grades_id_seq OWNED BY grades.id;


--
-- Name: groups; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE groups (
    id integer NOT NULL,
    name text NOT NULL
);


--
-- Name: groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE groups_id_seq OWNED BY groups.id;


--
-- Name: instructors; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE instructors (
    id integer NOT NULL,
    name text NOT NULL,
    nick text NOT NULL,
    capacity integer NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    modified_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    modified_by text
);


--
-- Name: instructors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE instructors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: instructors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE instructors_id_seq OWNED BY instructors.id;


--
-- Name: instructors_schedules; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE instructors_schedules (
    id integer NOT NULL,
    schedule_id integer,
    instructor_id integer,
    day text NOT NULL,
    avail_seat integer NOT NULL,
    CONSTRAINT instructors_schedules_day_check CHECK ((day = ANY (ARRAY['mon'::text, 'tue'::text, 'wed'::text, 'thu'::text, 'fri'::text, 'sat'::text, 'sun'::text])))
);


--
-- Name: instructors_schedules_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE instructors_schedules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: instructors_schedules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE instructors_schedules_id_seq OWNED BY instructors_schedules.id;


--
-- Name: pkgs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE pkgs (
    id integer NOT NULL,
    pkg_old text,
    level integer NOT NULL,
    course_id integer
);


--
-- Name: pkgs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE pkgs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pkgs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE pkgs_id_seq OWNED BY pkgs.id;


--
-- Name: prereqs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE prereqs (
    id integer NOT NULL,
    pkg_id integer,
    req_pkg_id integer
);


--
-- Name: prereqs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE prereqs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: prereqs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE prereqs_id_seq OWNED BY prereqs.id;


--
-- Name: programs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE programs (
    id integer NOT NULL,
    program text NOT NULL
);


--
-- Name: programs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE programs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: programs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE programs_id_seq OWNED BY programs.id;


--
-- Name: programs_instructors; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE programs_instructors (
    id integer NOT NULL,
    program_id integer,
    instructor_id integer
);


--
-- Name: programs_instructors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE programs_instructors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: programs_instructors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE programs_instructors_id_seq OWNED BY programs_instructors.id;


--
-- Name: provinces; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE provinces (
    id integer NOT NULL,
    code character varying(2) NOT NULL,
    name character varying(30) NOT NULL
);


--
-- Name: provinces_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE provinces_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: provinces_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE provinces_id_seq OWNED BY provinces.id;


--
-- Name: regencies_cities; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE regencies_cities (
    id integer NOT NULL,
    code character varying(4) NOT NULL,
    province_code character varying(2) NOT NULL,
    name character varying(30) NOT NULL
);


--
-- Name: regencies_cities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE regencies_cities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: regencies_cities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE regencies_cities_id_seq OWNED BY regencies_cities.id;


--
-- Name: schedules; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schedules (
    id integer NOT NULL,
    label text NOT NULL,
    time_slot text NOT NULL
);


--
-- Name: schedules_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE schedules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: schedules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE schedules_id_seq OWNED BY schedules.id;


--
-- Name: settings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE settings (
    id integer NOT NULL,
    var character varying(255) NOT NULL,
    value text,
    thing_id integer,
    thing_type character varying(30),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE settings_id_seq OWNED BY settings.id;


--
-- Name: students; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE students (
    id integer NOT NULL,
    name text NOT NULL,
    birthplace text,
    birthdate date,
    sex text NOT NULL,
    phone text,
    email text,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    modified_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    modified_by text,
    avatar_file_name character varying(255),
    avatar_content_type character varying(255),
    avatar_file_size integer,
    avatar_updated_at timestamp without time zone,
    biodata hstore,
    religion text,
    street_address text,
    district text,
    regency_city text,
    province text,
    registered_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    employment text DEFAULT 'belum bekerja'::text NOT NULL,
    CONSTRAINT students_sex_check CHECK ((sex = ANY (ARRAY['female'::text, 'male'::text])))
);


--
-- Name: students_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE students_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: students_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE students_id_seq OWNED BY students.id;


--
-- Name: students_pkgs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE students_pkgs (
    id integer NOT NULL,
    student_id integer,
    pkg_id integer
);


--
-- Name: students_pkgs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE students_pkgs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: students_pkgs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE students_pkgs_id_seq OWNED BY students_pkgs.id;


--
-- Name: students_pkgs_instructors_schedules; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE students_pkgs_instructors_schedules (
    id integer NOT NULL,
    students_pkg_id integer,
    instructors_schedule_id integer
);


--
-- Name: students_pkgs_instructors_schedules_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE students_pkgs_instructors_schedules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: students_pkgs_instructors_schedules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE students_pkgs_instructors_schedules_id_seq OWNED BY students_pkgs_instructors_schedules.id;


--
-- Name: students_qualifications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE students_qualifications (
    id integer NOT NULL,
    student_id integer,
    pkg_id integer,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    modified_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    modified_by text
);


--
-- Name: students_qualifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE students_qualifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: students_qualifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE students_qualifications_id_seq OWNED BY students_qualifications.id;


--
-- Name: students_records; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE students_records (
    id integer NOT NULL,
    student_id integer,
    pkg_id integer,
    started_on timestamp with time zone DEFAULT ('now'::text)::date NOT NULL,
    finished_on timestamp with time zone,
    status text DEFAULT 'active'::text NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    modified_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    modified_by text,
    CONSTRAINT students_records_status_check CHECK ((status = ANY (ARRAY['active'::text, 'finished'::text, 'failed'::text, 'abandoned'::text])))
);


--
-- Name: students_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE students_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: students_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE students_records_id_seq OWNED BY students_records.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    group_id integer,
    username text NOT NULL,
    fullname text NOT NULL,
    password_digest text NOT NULL,
    email text,
    password_reset_token character varying,
    password_reset_sent_at timestamp without time zone
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: users_instructors; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users_instructors (
    id integer NOT NULL,
    user_id integer,
    instructor_id integer
);


--
-- Name: users_instructors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_instructors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_instructors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_instructors_id_seq OWNED BY users_instructors.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY changes ALTER COLUMN id SET DEFAULT nextval('changes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY components ALTER COLUMN id SET DEFAULT nextval('components_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY courses ALTER COLUMN id SET DEFAULT nextval('courses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY districts ALTER COLUMN id SET DEFAULT nextval('districts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY grades ALTER COLUMN id SET DEFAULT nextval('grades_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY groups ALTER COLUMN id SET DEFAULT nextval('groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY instructors ALTER COLUMN id SET DEFAULT nextval('instructors_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY instructors_schedules ALTER COLUMN id SET DEFAULT nextval('instructors_schedules_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY pkgs ALTER COLUMN id SET DEFAULT nextval('pkgs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY prereqs ALTER COLUMN id SET DEFAULT nextval('prereqs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY programs ALTER COLUMN id SET DEFAULT nextval('programs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY programs_instructors ALTER COLUMN id SET DEFAULT nextval('programs_instructors_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY provinces ALTER COLUMN id SET DEFAULT nextval('provinces_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY regencies_cities ALTER COLUMN id SET DEFAULT nextval('regencies_cities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY schedules ALTER COLUMN id SET DEFAULT nextval('schedules_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY settings ALTER COLUMN id SET DEFAULT nextval('settings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY students ALTER COLUMN id SET DEFAULT nextval('students_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY students_pkgs ALTER COLUMN id SET DEFAULT nextval('students_pkgs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY students_pkgs_instructors_schedules ALTER COLUMN id SET DEFAULT nextval('students_pkgs_instructors_schedules_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY students_qualifications ALTER COLUMN id SET DEFAULT nextval('students_qualifications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY students_records ALTER COLUMN id SET DEFAULT nextval('students_records_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users_instructors ALTER COLUMN id SET DEFAULT nextval('users_instructors_id_seq'::regclass);


--
-- Name: changes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY changes
    ADD CONSTRAINT changes_pkey PRIMARY KEY (id);


--
-- Name: components_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY components
    ADD CONSTRAINT components_pkey PRIMARY KEY (id);


--
-- Name: courses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY courses
    ADD CONSTRAINT courses_pkey PRIMARY KEY (id);


--
-- Name: districts_code_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY districts
    ADD CONSTRAINT districts_code_key UNIQUE (code);


--
-- Name: districts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY districts
    ADD CONSTRAINT districts_pkey PRIMARY KEY (id);


--
-- Name: grades_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY grades
    ADD CONSTRAINT grades_pkey PRIMARY KEY (id);


--
-- Name: grades_students_record_id_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY grades
    ADD CONSTRAINT grades_students_record_id_key UNIQUE (students_record_id);


--
-- Name: groups_name_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY groups
    ADD CONSTRAINT groups_name_key UNIQUE (name);


--
-- Name: groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: instructor_schedule_day_unique; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY instructors_schedules
    ADD CONSTRAINT instructor_schedule_day_unique UNIQUE (schedule_id, instructor_id, day);


--
-- Name: instructors_name_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY instructors
    ADD CONSTRAINT instructors_name_key UNIQUE (name);


--
-- Name: instructors_nick_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY instructors
    ADD CONSTRAINT instructors_nick_key UNIQUE (nick);


--
-- Name: instructors_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY instructors
    ADD CONSTRAINT instructors_pkey PRIMARY KEY (id);


--
-- Name: instructors_schedules_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY instructors_schedules
    ADD CONSTRAINT instructors_schedules_pkey PRIMARY KEY (id);


--
-- Name: pkgs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pkgs
    ADD CONSTRAINT pkgs_pkey PRIMARY KEY (id);


--
-- Name: prereqs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY prereqs
    ADD CONSTRAINT prereqs_pkey PRIMARY KEY (id);


--
-- Name: programs_instructors_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY programs_instructors
    ADD CONSTRAINT programs_instructors_pkey PRIMARY KEY (id);


--
-- Name: programs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY programs
    ADD CONSTRAINT programs_pkey PRIMARY KEY (id);


--
-- Name: programs_program_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY programs
    ADD CONSTRAINT programs_program_key UNIQUE (program);


--
-- Name: provinces_code_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY provinces
    ADD CONSTRAINT provinces_code_key UNIQUE (code);


--
-- Name: provinces_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY provinces
    ADD CONSTRAINT provinces_pkey PRIMARY KEY (id);


--
-- Name: regencies_cities_code_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY regencies_cities
    ADD CONSTRAINT regencies_cities_code_key UNIQUE (code);


--
-- Name: regencies_cities_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY regencies_cities
    ADD CONSTRAINT regencies_cities_pkey PRIMARY KEY (id);


--
-- Name: schedules_label_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY schedules
    ADD CONSTRAINT schedules_label_key UNIQUE (label);


--
-- Name: schedules_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY schedules
    ADD CONSTRAINT schedules_pkey PRIMARY KEY (id);


--
-- Name: schedules_time_slot_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY schedules
    ADD CONSTRAINT schedules_time_slot_key UNIQUE (time_slot);


--
-- Name: settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: student_pkg_instructor_unique; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY students_pkgs_instructors_schedules
    ADD CONSTRAINT student_pkg_instructor_unique UNIQUE (students_pkg_id, instructors_schedule_id);


--
-- Name: student_pkg_unique; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY students_pkgs
    ADD CONSTRAINT student_pkg_unique UNIQUE (student_id, pkg_id);


--
-- Name: students_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY students
    ADD CONSTRAINT students_pkey PRIMARY KEY (id);


--
-- Name: students_pkgs_instructors_schedules_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY students_pkgs_instructors_schedules
    ADD CONSTRAINT students_pkgs_instructors_schedules_pkey PRIMARY KEY (id);


--
-- Name: students_pkgs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY students_pkgs
    ADD CONSTRAINT students_pkgs_pkey PRIMARY KEY (id);


--
-- Name: students_qualifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY students_qualifications
    ADD CONSTRAINT students_qualifications_pkey PRIMARY KEY (id);


--
-- Name: students_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY students_records
    ADD CONSTRAINT students_records_pkey PRIMARY KEY (id);


--
-- Name: user_instructor_unique; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users_instructors
    ADD CONSTRAINT user_instructor_unique UNIQUE (user_id, instructor_id);


--
-- Name: users_instructors_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users_instructors
    ADD CONSTRAINT users_instructors_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: changes_action_tstamp; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX changes_action_tstamp ON changes USING btree (action_tstamp);


--
-- Name: changes_modified_by; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX changes_modified_by ON changes USING btree (modified_by);


--
-- Name: changes_table_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX changes_table_name ON changes USING btree (table_name);


--
-- Name: components_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX components_created_at ON components USING btree (created_at);


--
-- Name: districts_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX districts_name ON districts USING btree (name);


--
-- Name: index_settings_on_thing_type_and_thing_id_and_var; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_settings_on_thing_type_and_thing_id_and_var ON settings USING btree (thing_type, thing_id, var);


--
-- Name: students_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX students_name ON students USING btree (name);


--
-- Name: students_registered_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX students_registered_at ON students USING btree (registered_at);


--
-- Name: students_religion_sex; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX students_religion_sex ON students USING btree (religion, sex);


--
-- Name: components_if_modified; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER components_if_modified AFTER INSERT OR DELETE OR UPDATE ON components FOR EACH ROW EXECUTE PROCEDURE if_modified_func();


--
-- Name: components_update_timestamp; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER components_update_timestamp BEFORE UPDATE ON components FOR EACH ROW EXECUTE PROCEDURE update_timestamp();


--
-- Name: grades_cache_student; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER grades_cache_student BEFORE INSERT ON grades FOR EACH ROW EXECUTE PROCEDURE cache_student();


--
-- Name: grades_if_modified; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER grades_if_modified AFTER INSERT OR DELETE OR UPDATE ON grades FOR EACH ROW EXECUTE PROCEDURE if_modified_func();


--
-- Name: grades_update_student_cache; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER grades_update_student_cache AFTER UPDATE OF student_id ON students_records FOR EACH ROW EXECUTE PROCEDURE update_student_cache();


--
-- Name: grades_update_userstamp; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER grades_update_userstamp BEFORE INSERT OR UPDATE ON grades FOR EACH ROW EXECUTE PROCEDURE update_userstamp();


--
-- Name: instructors_if_modified; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER instructors_if_modified AFTER INSERT OR DELETE OR UPDATE ON instructors FOR EACH ROW EXECUTE PROCEDURE if_modified_func();


--
-- Name: instructors_schedules_if_modified; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER instructors_schedules_if_modified AFTER INSERT OR DELETE OR UPDATE ON instructors_schedules FOR EACH ROW EXECUTE PROCEDURE if_modified_func();


--
-- Name: instructors_schedules_init_avail_seat; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER instructors_schedules_init_avail_seat BEFORE INSERT ON instructors_schedules FOR EACH ROW EXECUTE PROCEDURE init_avail_seat();


--
-- Name: instructors_schedules_seat_change; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER instructors_schedules_seat_change AFTER UPDATE OF avail_seat ON instructors_schedules FOR EACH ROW EXECUTE PROCEDURE if_avail_seat_change();


--
-- Name: instructors_update_avail_seat_by_cap; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER instructors_update_avail_seat_by_cap AFTER UPDATE ON instructors FOR EACH ROW EXECUTE PROCEDURE update_avail_seat_by_cap();


--
-- Name: instructors_update_timestamp; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER instructors_update_timestamp BEFORE UPDATE ON instructors FOR EACH ROW EXECUTE PROCEDURE update_timestamp();


--
-- Name: instructors_update_userstamp; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER instructors_update_userstamp BEFORE INSERT OR UPDATE ON instructors FOR EACH ROW EXECUTE PROCEDURE update_userstamp();


--
-- Name: programs_instructors_if_modified; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER programs_instructors_if_modified AFTER INSERT OR DELETE OR UPDATE ON programs_instructors FOR EACH ROW EXECUTE PROCEDURE if_modified_func();


--
-- Name: students_check_registered_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER students_check_registered_at BEFORE UPDATE ON students FOR EACH ROW EXECUTE PROCEDURE check_registered_at();


--
-- Name: students_if_modified; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER students_if_modified AFTER INSERT OR DELETE OR UPDATE ON students FOR EACH ROW EXECUTE PROCEDURE if_modified_func();


--
-- Name: students_pkgs_if_modified; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER students_pkgs_if_modified AFTER INSERT OR DELETE OR UPDATE ON students_pkgs FOR EACH ROW EXECUTE PROCEDURE if_modified_func();


--
-- Name: students_pkgs_instructors_schedules_check_avail_seat; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER students_pkgs_instructors_schedules_check_avail_seat BEFORE INSERT ON students_pkgs_instructors_schedules FOR EACH ROW EXECUTE PROCEDURE check_avail_seat();


--
-- Name: students_pkgs_instructors_schedules_check_instructors_program; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER students_pkgs_instructors_schedules_check_instructors_program BEFORE INSERT ON students_pkgs_instructors_schedules FOR EACH ROW EXECUTE PROCEDURE check_instructors_program();


--
-- Name: students_pkgs_instructors_schedules_check_unique_schedule; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER students_pkgs_instructors_schedules_check_unique_schedule BEFORE INSERT ON students_pkgs_instructors_schedules FOR EACH ROW EXECUTE PROCEDURE check_unique_schedule();


--
-- Name: students_pkgs_instructors_schedules_if_modified; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER students_pkgs_instructors_schedules_if_modified AFTER INSERT OR DELETE OR UPDATE ON students_pkgs_instructors_schedules FOR EACH ROW EXECUTE PROCEDURE if_modified_func();


--
-- Name: students_pkgs_instructors_schedules_update_avail_seat; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER students_pkgs_instructors_schedules_update_avail_seat AFTER INSERT OR DELETE ON students_pkgs_instructors_schedules FOR EACH ROW EXECUTE PROCEDURE update_avail_seat();


--
-- Name: students_qualifications_if_modified; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER students_qualifications_if_modified AFTER INSERT OR DELETE OR UPDATE ON students_qualifications FOR EACH ROW EXECUTE PROCEDURE if_modified_func();


--
-- Name: students_qualifications_update_timestamp; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER students_qualifications_update_timestamp BEFORE UPDATE ON students_qualifications FOR EACH ROW EXECUTE PROCEDURE update_timestamp();


--
-- Name: students_qualifications_update_userstamp; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER students_qualifications_update_userstamp BEFORE INSERT OR UPDATE ON students_qualifications FOR EACH ROW EXECUTE PROCEDURE update_userstamp();


--
-- Name: students_records_if_modified; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER students_records_if_modified AFTER INSERT OR DELETE OR UPDATE ON students_records FOR EACH ROW EXECUTE PROCEDURE if_modified_func();


--
-- Name: students_records_update_timestamp; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER students_records_update_timestamp BEFORE UPDATE ON students_records FOR EACH ROW EXECUTE PROCEDURE update_timestamp();


--
-- Name: students_records_update_userstamp; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER students_records_update_userstamp BEFORE INSERT OR UPDATE ON students_records FOR EACH ROW EXECUTE PROCEDURE update_userstamp();


--
-- Name: students_update_timestamp; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER students_update_timestamp BEFORE UPDATE ON students FOR EACH ROW EXECUTE PROCEDURE update_timestamp();


--
-- Name: students_update_userstamp; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER students_update_userstamp BEFORE INSERT OR UPDATE ON students FOR EACH ROW EXECUTE PROCEDURE update_userstamp();


--
-- Name: components_course_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY components
    ADD CONSTRAINT components_course_id_fkey FOREIGN KEY (course_id) REFERENCES courses(id);


--
-- Name: courses_head_instructor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY courses
    ADD CONSTRAINT courses_head_instructor_id_fkey FOREIGN KEY (head_instructor_id) REFERENCES instructors(id);


--
-- Name: courses_program_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY courses
    ADD CONSTRAINT courses_program_id_fkey FOREIGN KEY (program_id) REFERENCES programs(id);


--
-- Name: districts_regency_city_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY districts
    ADD CONSTRAINT districts_regency_city_code_fkey FOREIGN KEY (regency_city_code) REFERENCES regencies_cities(code);


--
-- Name: grades_component_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY grades
    ADD CONSTRAINT grades_component_id_fkey FOREIGN KEY (component_id) REFERENCES components(id);


--
-- Name: grades_instructor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY grades
    ADD CONSTRAINT grades_instructor_id_fkey FOREIGN KEY (instructor_id) REFERENCES instructors(id);


--
-- Name: grades_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY grades
    ADD CONSTRAINT grades_student_id_fkey FOREIGN KEY (student_id) REFERENCES students(id);


--
-- Name: grades_students_record_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY grades
    ADD CONSTRAINT grades_students_record_id_fkey FOREIGN KEY (students_record_id) REFERENCES students_records(id);


--
-- Name: instructors_schedules_instructor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY instructors_schedules
    ADD CONSTRAINT instructors_schedules_instructor_id_fkey FOREIGN KEY (instructor_id) REFERENCES instructors(id);


--
-- Name: instructors_schedules_schedule_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY instructors_schedules
    ADD CONSTRAINT instructors_schedules_schedule_id_fkey FOREIGN KEY (schedule_id) REFERENCES schedules(id);


--
-- Name: pkgs_course_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY pkgs
    ADD CONSTRAINT pkgs_course_id_fkey FOREIGN KEY (course_id) REFERENCES courses(id);


--
-- Name: prereqs_pkg_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY prereqs
    ADD CONSTRAINT prereqs_pkg_id_fkey FOREIGN KEY (pkg_id) REFERENCES pkgs(id);


--
-- Name: prereqs_req_pkg_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY prereqs
    ADD CONSTRAINT prereqs_req_pkg_id_fkey FOREIGN KEY (req_pkg_id) REFERENCES pkgs(id);


--
-- Name: programs_instructors_instructor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY programs_instructors
    ADD CONSTRAINT programs_instructors_instructor_id_fkey FOREIGN KEY (instructor_id) REFERENCES instructors(id);


--
-- Name: programs_instructors_program_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY programs_instructors
    ADD CONSTRAINT programs_instructors_program_id_fkey FOREIGN KEY (program_id) REFERENCES programs(id);


--
-- Name: regencies_cities_province_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY regencies_cities
    ADD CONSTRAINT regencies_cities_province_code_fkey FOREIGN KEY (province_code) REFERENCES provinces(code);


--
-- Name: students_pkgs_instructors_schedule_instructors_schedule_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY students_pkgs_instructors_schedules
    ADD CONSTRAINT students_pkgs_instructors_schedule_instructors_schedule_id_fkey FOREIGN KEY (instructors_schedule_id) REFERENCES instructors_schedules(id);


--
-- Name: students_pkgs_instructors_schedules_students_pkg_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY students_pkgs_instructors_schedules
    ADD CONSTRAINT students_pkgs_instructors_schedules_students_pkg_id_fkey FOREIGN KEY (students_pkg_id) REFERENCES students_pkgs(id) ON DELETE CASCADE;


--
-- Name: students_pkgs_pkg_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY students_pkgs
    ADD CONSTRAINT students_pkgs_pkg_id_fkey FOREIGN KEY (pkg_id) REFERENCES pkgs(id);


--
-- Name: students_pkgs_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY students_pkgs
    ADD CONSTRAINT students_pkgs_student_id_fkey FOREIGN KEY (student_id) REFERENCES students(id);


--
-- Name: students_qualifications_pkg_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY students_qualifications
    ADD CONSTRAINT students_qualifications_pkg_id_fkey FOREIGN KEY (pkg_id) REFERENCES pkgs(id);


--
-- Name: students_qualifications_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY students_qualifications
    ADD CONSTRAINT students_qualifications_student_id_fkey FOREIGN KEY (student_id) REFERENCES students(id);


--
-- Name: students_records_pkg_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY students_records
    ADD CONSTRAINT students_records_pkg_id_fkey FOREIGN KEY (pkg_id) REFERENCES pkgs(id);


--
-- Name: students_records_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY students_records
    ADD CONSTRAINT students_records_student_id_fkey FOREIGN KEY (student_id) REFERENCES students(id);


--
-- Name: users_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_group_id_fkey FOREIGN KEY (group_id) REFERENCES groups(id);


--
-- Name: users_instructors_instructor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users_instructors
    ADD CONSTRAINT users_instructors_instructor_id_fkey FOREIGN KEY (instructor_id) REFERENCES instructors(id);


--
-- Name: users_instructors_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users_instructors
    ADD CONSTRAINT users_instructors_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: public; Type: ACL; Schema: -; Owner: -
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--
SQL
  end
end
