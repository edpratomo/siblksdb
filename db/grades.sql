CREATE TABLE courses(
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL
);

INSERT INTO courses(name) VALUES('MS Word');
INSERT INTO courses(name) VALUES('MS Excel');
INSERT INTO courses(name) VALUES('MS PowerPoint');
INSERT INTO courses(name) VALUES('MS Access');
INSERT INTO courses(name) VALUES('Corel Draw');
INSERT INTO courses(name) VALUES('Adobe Photoshop');
INSERT INTO courses(name) VALUES('AutoCAD 2D');
INSERT INTO courses(name) VALUES('AutoCAD 3D');
INSERT INTO courses(name) VALUES('AC');
INSERT INTO courses(name) VALUES('Las Dasar');
INSERT INTO courses(name) VALUES('Mekanik Bubut');
INSERT INTO courses(name) VALUES('Sepeda Motor');
INSERT INTO courses(name) VALUES('Listrik Rumah Tangga & Industri');
INSERT INTO courses(name) VALUES('Bahasa Inggris');

ALTER TABLE pkgs ADD COLUMN course_id INTEGER REFERENCES courses(id);

UPDATE pkgs SET course_id = 1 WHERE id IN (1, 2, 3, 4);
UPDATE pkgs SET course_id = 2 WHERE id IN (5, 6, 7);
UPDATE pkgs SET course_id = 3 WHERE id IN (8, 9);
UPDATE pkgs SET course_id = 4 WHERE id IN (10);
UPDATE pkgs SET course_id = 5 WHERE id IN (11, 12);
UPDATE pkgs SET course_id = 6 WHERE id IN (13);
UPDATE pkgs SET course_id = 7 WHERE id IN (14);
UPDATE pkgs SET course_id = 8 WHERE id IN (15); 
UPDATE pkgs SET course_id = 9 WHERE id IN (18, 28);
UPDATE pkgs SET course_id = 10 WHERE id IN (19, 20);
UPDATE pkgs SET course_id = 11 WHERE id IN (21, 22, 23);
UPDATE pkgs SET course_id = 12 WHERE id IN (24, 25, 26);
UPDATE pkgs SET course_id = 13 WHERE id IN (16, 17, 27);
UPDATE pkgs SET course_id = 14 WHERE id IN (29, 30, 31);

-- komponen-komponen nilai
CREATE TABLE components (
  id SERIAL PRIMARY KEY,
  content TEXT NOT NULL DEFAULT '',
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT clock_timestamp(),
  modified_by TEXT,
  course_id INTEGER NOT NULL REFERENCES courses(id)
);

CREATE INDEX components_created_at ON components(created_at);

CREATE TABLE grades (
  id SERIAL PRIMARY KEY,
  instructor_id INTEGER NOT NULL REFERENCES instructors(id),
  students_record_id INTEGER NOT NULL UNIQUE REFERENCES students_records(id),
  student_id INTEGER REFERENCES students(id),
  component_id INTEGER REFERENCES components(id),
  value hstore NOT NULL DEFAULT '',
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT clock_timestamp(),
  modified_by TEXT
);
