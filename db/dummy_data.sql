
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

INSERT INTO instructors(name, nick, modified_by) VALUES('Homer Simpson', 'homer', 1);
INSERT INTO instructors(name, nick, modified_by) VALUES('Sonny Corleone', 'sonny', 1);
INSERT INTO instructors(name, nick, modified_by) VALUES('Fredo Corleone', 'fredo', 1);
INSERT INTO instructors(name, nick, modified_by) VALUES('Michael Corleone', 'mickey', 1);
INSERT INTO instructors(name, nick, modified_by) VALUES('Vito Corleone', 'vito', 1);
INSERT INTO instructors(name, nick, modified_by) VALUES('Connie Corleone', 'connie', 1);

INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(1, 2);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(2, 2);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(3, 2);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(4, 2);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(5, 2);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(6, 2);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(7, 2);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(8, 2);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(9, 2);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(10, 2);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(11, 2);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(12, 2);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(13, 2);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(14, 2);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(15, 2);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(16, 2);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(17, 2);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(18, 2);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(19, 2);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(20, 2);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(22, 2);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(23, 2);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(24, 2);

INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(1, 3);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(2, 3);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(3, 3);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(4, 3);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(5, 3);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(6, 3);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(7, 3);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(8, 3);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(9, 3);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(10, 3);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(11, 3);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(12, 3);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(13, 3);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(14, 3);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(15, 3);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(16, 3);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(17, 3);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(18, 3);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(19, 3);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(20, 3);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(22, 3);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(23, 3);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(24, 3);

INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(1, 4);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(2, 4);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(3, 4);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(4, 4);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(5, 4);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(6, 4);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(7, 4);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(8, 4);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(9, 4);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(10, 4);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(11, 4);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(12, 4);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(13, 4);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(14, 4);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(15, 4);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(16, 4);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(17, 4);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(18, 4);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(19, 4);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(20, 4);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(22, 4);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(23, 4);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(24, 4);

INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(1, 5);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(2, 5);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(3, 5);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(4, 5);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(5, 5);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(6, 5);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(7, 5);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(8, 5);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(9, 5);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(10, 5);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(11, 5);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(12, 5);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(13, 5);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(14, 5);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(15, 5);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(16, 5);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(17, 5);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(18, 5);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(19, 5);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(20, 5);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(22, 5);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(23, 5);
INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(24, 5);

INSERT INTO pkgs_schedules_instructors(pkgs_schedule_id, instructor_id) VALUES(21, 6);
