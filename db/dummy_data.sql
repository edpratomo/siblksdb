
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

-- dummy students
INSERT INTO students(name, sex, modified_by) VALUES('Gamawan Fauzi', 'male', 1);
INSERT INTO students(name, sex, modified_by) VALUES('Raden Mohammad Marty Muliana Natalegawa', 'male', 1);
INSERT INTO students(name, sex, modified_by) VALUES('Purnomo Yusgiantoro', 'male', 1);
INSERT INTO students(name, sex, modified_by) VALUES('Patrialis Akbar', 'male', 1);
INSERT INTO students(name, sex, modified_by) VALUES('Sri Mulyani Indrawati', 'female', 1);
INSERT INTO students(name, sex, modified_by) VALUES('Darwin Zahedy Saleh', 'male', 1);
INSERT INTO students(name, sex, modified_by) VALUES('Mohamad Suleman Hidayat', 'male', 1);
INSERT INTO students(name, sex, modified_by) VALUES('Mari E. Pangestu', 'female', 1);
INSERT INTO students(name, sex, modified_by) VALUES('Suswono', 'male', 1);
INSERT INTO students(name, sex, modified_by) VALUES('Zulkifli Hasan', 'male', 1);
INSERT INTO students(name, sex, modified_by) VALUES('Freddy Numberi', 'male', 1);
INSERT INTO students(name, sex, modified_by) VALUES('Fadel Muhammad', 'male', 1);
INSERT INTO students(name, sex, modified_by) VALUES('A. Muhaimin Iskandar', 'male', 1);
INSERT INTO students(name, sex, modified_by) VALUES('Djoko Kirmanto', 'male', 1);
INSERT INTO students(name, sex, modified_by) VALUES('Endang Rahayu Sedyaningsih', 'female', 1);
INSERT INTO students(name, sex, modified_by) VALUES('Muhammad Nuh', 'male', 1);
INSERT INTO students(name, sex, modified_by) VALUES('Salim Segaf Al-Jufrie', 'male', 1);
INSERT INTO students(name, sex, modified_by) VALUES('Suryadharma Ali', 'male', 1);
INSERT INTO students(name, sex, modified_by) VALUES('Jero Wacik', 'male', 1);
INSERT INTO students(name, sex, modified_by) VALUES('Tifatul Sembiring', 'male', 1);
INSERT INTO students(name, sex, modified_by) VALUES('Djoko Suyanto', 'male', 1);
INSERT INTO students(name, sex, modified_by) VALUES('Hatta Radjasa', 'male', 1);
INSERT INTO students(name, sex, modified_by) VALUES('R. Agung Laksono', 'male', 1);
INSERT INTO students(name, sex, modified_by) VALUES('Sudi Silalahi', 'male', 1);
INSERT INTO students(name, sex, modified_by) VALUES('Suharna Surapranata', 'male', 1);
INSERT INTO students(name, sex, modified_by) VALUES('Syarif Hasan', 'male', 1);
INSERT INTO students(name, sex, modified_by) VALUES('Gusti M. Hatta', 'male', 1);
INSERT INTO students(name, sex, modified_by) VALUES('Linda Amalia Sari', 'female', 1);
INSERT INTO students(name, sex, modified_by) VALUES('E.E. Mangindaan', 'male', 1);
INSERT INTO students(name, sex, modified_by) VALUES('Armida Alisjahbana', 'female', 1);
INSERT INTO students(name, sex, modified_by) VALUES('Musfata Abubakar', 'male', 1);
INSERT INTO students(name, sex, modified_by) VALUES('Andi Alfian Mallarangeng', 'male', 1);
INSERT INTO students(name, sex, modified_by) VALUES('Ahmad Helmy Faishal Zaini', 'male', 1);
INSERT INTO students(name, sex, modified_by) VALUES('Suharso Manoarfa', 'male', 1);
INSERT INTO students(name, sex, modified_by) VALUES('Hendarman Supandji', 'male', 1);
INSERT INTO students(name, sex, modified_by) VALUES('Djoko Santoso', 'male', 1);
INSERT INTO students(name, sex, modified_by) VALUES('Bambang Hendarso Danuri', 'male', 1);
INSERT INTO students(name, sex, modified_by) VALUES('Kuntoro Mangkusubroto', 'male', 1);
INSERT INTO students(name, sex, modified_by) VALUES('Sutanto', 'male', 1);
INSERT INTO students(name, sex, modified_by) VALUES('Gita Wirjawan', 'male', 1);

UPDATE students SET birthdate = '1970-01-01', birthplace = 'Jakarta';

INSERT INTO instructors(name, nick, capacity, modified_by) VALUES('Homer Simpson', 'homer', 10, 1);
INSERT INTO instructors(name, nick, capacity, modified_by) VALUES('Sonny Corleone', 'sonny', 10, 1);
INSERT INTO instructors(name, nick, capacity, modified_by) VALUES('Fredo Corleone', 'fredo', 10, 1);
INSERT INTO instructors(name, nick, capacity, modified_by) VALUES('Michael Corleone', 'mickey', 10, 1);
INSERT INTO instructors(name, nick, capacity, modified_by) VALUES('Vito Corleone', 'vito', 10, 1);
INSERT INTO instructors(name, nick, capacity, modified_by) VALUES('Connie Corleone', 'connie', 10, 1);
INSERT INTO instructors(name, nick, capacity, modified_by) VALUES('Tony Stark', 'tony', 10, 1);

-- populate instructors_schedules table
SELECT populate_instructors_schedules();

INSERT INTO instructors_schedules(schedule_id, instructor_id, day) VALUES(1, 7, 'mon');

-- populate programs_instructors table
SELECT populate_programs_instructors();

INSERT INTO programs_instructors(program_id, instructor_id) VALUES(5, 7); 
INSERT INTO programs_instructors(program_id, instructor_id) VALUES(6, 7);

