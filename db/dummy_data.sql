
\set ON_ERROR_STOP on

\prompt 'Populate students and instructors with dummy data? ' yes_or_no

\set Do_Dummies '\'' :yes_or_no '\''

CREATE TEMP TABLE Dummies AS SELECT :Do_Dummies::text AS confirm;

DO $$
BEGIN
  IF EXISTS(SELECT * FROM Dummies WHERE confirm NOT IN('yes', 'y', 'Y')) THEN
    RAISE EXCEPTION 'Exiting..';
  ELSE
    RAISE NOTICE 'Populating students and instructors tables..';
  END IF;
END
$$;

BEGIN;
CREATE TEMPORARY TABLE current_app_user(username TEXT) ON COMMIT DROP;
INSERT INTO current_app_user VALUES('homer');

-- dummy students
INSERT INTO students(name, sex) VALUES('Gamawan Fauzi', 'male');
INSERT INTO students(name, sex) VALUES('Raden Mohammad Marty Muliana Natalegawa', 'male');
INSERT INTO students(name, sex) VALUES('Purnomo Yusgiantoro', 'male');
INSERT INTO students(name, sex) VALUES('Patrialis Akbar', 'male');
INSERT INTO students(name, sex) VALUES('Sri Mulyani Indrawati', 'female');
INSERT INTO students(name, sex) VALUES('Darwin Zahedy Saleh', 'male');
INSERT INTO students(name, sex) VALUES('Mohamad Suleman Hidayat', 'male');
INSERT INTO students(name, sex) VALUES('Mari E. Pangestu', 'female');
INSERT INTO students(name, sex) VALUES('Suswono', 'male');
INSERT INTO students(name, sex) VALUES('Zulkifli Hasan', 'male');
INSERT INTO students(name, sex) VALUES('Freddy Numberi', 'male');
INSERT INTO students(name, sex) VALUES('Fadel Muhammad', 'male');
INSERT INTO students(name, sex) VALUES('A. Muhaimin Iskandar', 'male');
INSERT INTO students(name, sex) VALUES('Djoko Kirmanto', 'male');
INSERT INTO students(name, sex) VALUES('Endang Rahayu Sedyaningsih', 'female');
INSERT INTO students(name, sex) VALUES('Muhammad Nuh', 'male');
INSERT INTO students(name, sex) VALUES('Salim Segaf Al-Jufrie', 'male');
INSERT INTO students(name, sex) VALUES('Suryadharma Ali', 'male');
INSERT INTO students(name, sex) VALUES('Jero Wacik', 'male');
INSERT INTO students(name, sex) VALUES('Tifatul Sembiring', 'male');
INSERT INTO students(name, sex) VALUES('Djoko Suyanto', 'male');
INSERT INTO students(name, sex) VALUES('Hatta Radjasa', 'male');
INSERT INTO students(name, sex) VALUES('R. Agung Laksono', 'male');
INSERT INTO students(name, sex) VALUES('Sudi Silalahi', 'male');
INSERT INTO students(name, sex) VALUES('Suharna Surapranata', 'male');
INSERT INTO students(name, sex) VALUES('Syarif Hasan', 'male');
INSERT INTO students(name, sex) VALUES('Gusti M. Hatta', 'male');
INSERT INTO students(name, sex) VALUES('Linda Amalia Sari', 'female');
INSERT INTO students(name, sex) VALUES('E.E. Mangindaan', 'male');
INSERT INTO students(name, sex) VALUES('Armida Alisjahbana', 'female');
INSERT INTO students(name, sex) VALUES('Musfata Abubakar', 'male');
INSERT INTO students(name, sex) VALUES('Andi Alfian Mallarangeng', 'male');
INSERT INTO students(name, sex) VALUES('Ahmad Helmy Faishal Zaini', 'male');
INSERT INTO students(name, sex) VALUES('Suharso Manoarfa', 'male');
INSERT INTO students(name, sex) VALUES('Hendarman Supandji', 'male');
INSERT INTO students(name, sex) VALUES('Djoko Santoso', 'male');
INSERT INTO students(name, sex) VALUES('Bambang Hendarso Danuri', 'male');
INSERT INTO students(name, sex) VALUES('Kuntoro Mangkusubroto', 'male');
INSERT INTO students(name, sex) VALUES('Sutanto', 'male');
INSERT INTO students(name, sex) VALUES('Gita Wirjawan', 'male');

UPDATE students SET birthdate = '1970-01-01', birthplace = 'Jakarta';

INSERT INTO instructors(name, nick, capacity) VALUES('Homer Simpson', 'homer', 10);
INSERT INTO instructors(name, nick, capacity) VALUES('Sonny Corleone', 'sonny', 10);
INSERT INTO instructors(name, nick, capacity) VALUES('Fredo Corleone', 'fredo', 10);
INSERT INTO instructors(name, nick, capacity) VALUES('Michael Corleone', 'mickey', 10);
INSERT INTO instructors(name, nick, capacity) VALUES('Vito Corleone', 'vito', 10);
INSERT INTO instructors(name, nick, capacity) VALUES('Connie Corleone', 'connie', 10);
INSERT INTO instructors(name, nick, capacity) VALUES('Tony Stark', 'tony', 10);

-- populate instructors_schedules table
SELECT populate_instructors_schedules();

INSERT INTO instructors_schedules(schedule_id, instructor_id, day) VALUES(1, 7, 'mon');

-- populate programs_instructors table
SELECT populate_programs_instructors();

INSERT INTO programs_instructors(program_id, instructor_id) VALUES(5, 7); 
INSERT INTO programs_instructors(program_id, instructor_id) VALUES(6, 7);

COMMIT;
