-- a published exam is read-only, since it is attached to students_records which is permanent.
-- as long as published_by is NULL, an exam is read/write
CREATE TABLE exams(
  id SERIAL PRIMARY KEY,
  pkg_id INTEGER REFERENCES pkgs(id),
  name TEXT NOT NULL DEFAULT 'Generic',
  annotation TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT clock_timestamp(),
  modified_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT clock_timestamp(),
  modified_by TEXT,
  published_at TIMESTAMP WITH TIME ZONE,
  published_by TEXT
);

-- this is optionally used for calculating overall grade (for practice exam).
-- if weight value is not given, it can be used as grouping of components in the grade sheet
CREATE TABLE grade_weights (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  weight FLOAT
);

CREATE TABLE exam_components (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  sequence INTEGER NOT NULL,
  scale FLOAT NOT NULL,
  grade_weight_id INTEGER REFERENCES grade_weights(id)
);

-- join table for exams and exam_components (many to many)
-- on the UI, this facilitates creating an "alias" of an existing exam.
CREATE TABLE exams_exam_components (
  id SERIAL PRIMARY KEY,
  exam_id INTEGER REFERENCES exams(id),
  exam_component_id INTEGER REFERENCES exam_components(id),
  CONSTRAINT exam_unique UNIQUE(exam_id, exam_component_id)
);

CREATE TABLE grades (
  id SERIAL PRIMARY KEY,
  instructor_id INTEGER REFERENCES instructors(id),
  students_record_id INTEGER REFERENCES students_records(id),
  exams_exam_component_id INTEGER REFERENCES exams_exam_components(id),
  grade FLOAT
);

INSERT INTO exams(pkg_id, name) VALUES(1, 'Obesitas');

INSERT INTO grade_weights(name) VALUES('Paragraf');
INSERT INTO grade_weights(name) VALUES('Gambar');
INSERT INTO grade_weights(name) VALUES('Page Setup');
INSERT INTO grade_weights(name) VALUES('Format Font');

INSERT INTO exam_components(name, sequence, scale, grade_weight_id) VALUES('Indentasi',        1, 10,  1);
INSERT INTO exam_components(name, sequence, scale, grade_weight_id) VALUES('Perataan Teks',    2, 5,   1);
INSERT INTO exam_components(name, sequence, scale, grade_weight_id) VALUES('Jarak Baris',      3, 7.5, 1);
INSERT INTO exam_components(name, sequence, scale, grade_weight_id) VALUES('Highlight',        4, 5,   1);
INSERT INTO exam_components(name, sequence, scale, grade_weight_id) VALUES('Simbol',           5, 5,   2);
INSERT INTO exam_components(name, sequence, scale, grade_weight_id) VALUES('Text Wrap',        6, 10,  2);
INSERT INTO exam_components(name, sequence, scale, grade_weight_id) VALUES('Image Control',    7, 5,   2);
INSERT INTO exam_components(name, sequence, scale, grade_weight_id) VALUES('Margins',          8, 5,   3);
INSERT INTO exam_components(name, sequence, scale, grade_weight_id) VALUES('Paper Size',       9, 5,   3);
INSERT INTO exam_components(name, sequence, scale, grade_weight_id) VALUES('Effect',          10, 10,  3);
INSERT INTO exam_components(name, sequence, scale, grade_weight_id) VALUES('Posisi Karakter', 11, 10,  4);
INSERT INTO exam_components(name, sequence, scale, grade_weight_id) VALUES('Spasi Karakter',  12, 10,  4);
INSERT INTO exam_components(name, sequence, scale) VALUES('Header dan Footer',                13, 7.5);
INSERT INTO exam_components(name, sequence, scale) VALUES('Ketelitian dan Kerapihan',         14, 5);

INSERT INTO exams_exam_components(exam_id, exam_component_id) VALUES(1, 1);
INSERT INTO exams_exam_components(exam_id, exam_component_id) VALUES(1, 2);
INSERT INTO exams_exam_components(exam_id, exam_component_id) VALUES(1, 3);
INSERT INTO exams_exam_components(exam_id, exam_component_id) VALUES(1, 4);
INSERT INTO exams_exam_components(exam_id, exam_component_id) VALUES(1, 5);
INSERT INTO exams_exam_components(exam_id, exam_component_id) VALUES(1, 6);
INSERT INTO exams_exam_components(exam_id, exam_component_id) VALUES(1, 7);
INSERT INTO exams_exam_components(exam_id, exam_component_id) VALUES(1, 8);
INSERT INTO exams_exam_components(exam_id, exam_component_id) VALUES(1, 9);
INSERT INTO exams_exam_components(exam_id, exam_component_id) VALUES(1, 10);
INSERT INTO exams_exam_components(exam_id, exam_component_id) VALUES(1, 11);
INSERT INTO exams_exam_components(exam_id, exam_component_id) VALUES(1, 12);
INSERT INTO exams_exam_components(exam_id, exam_component_id) VALUES(1, 13);
INSERT INTO exams_exam_components(exam_id, exam_component_id) VALUES(1, 14);

-- create more exams for MS Word Level 1, but only aliases due to the same components and weights
INSERT INTO exams(pkg_id, name) VALUES(1, 'Mata');

INSERT INTO exams_exam_components(exam_id, exam_component_id) VALUES(2, 1);
INSERT INTO exams_exam_components(exam_id, exam_component_id) VALUES(2, 2);
INSERT INTO exams_exam_components(exam_id, exam_component_id) VALUES(2, 3);
INSERT INTO exams_exam_components(exam_id, exam_component_id) VALUES(2, 4);
INSERT INTO exams_exam_components(exam_id, exam_component_id) VALUES(2, 5);
INSERT INTO exams_exam_components(exam_id, exam_component_id) VALUES(2, 6);
INSERT INTO exams_exam_components(exam_id, exam_component_id) VALUES(2, 7);
INSERT INTO exams_exam_components(exam_id, exam_component_id) VALUES(2, 8);
INSERT INTO exams_exam_components(exam_id, exam_component_id) VALUES(2, 9);
INSERT INTO exams_exam_components(exam_id, exam_component_id) VALUES(2, 10);
INSERT INTO exams_exam_components(exam_id, exam_component_id) VALUES(2, 11);
INSERT INTO exams_exam_components(exam_id, exam_component_id) VALUES(2, 12);
INSERT INTO exams_exam_components(exam_id, exam_component_id) VALUES(2, 13);
INSERT INTO exams_exam_components(exam_id, exam_component_id) VALUES(2, 14);

UPDATE exams SET modified_by = 'homer';
UPDATE exams SET published_at = '2015-09-09', published_by = 'homer';

CREATE TRIGGER exams_if_modified 
 AFTER INSERT OR UPDATE OR DELETE ON exams
  FOR EACH ROW EXECUTE PROCEDURE if_modified_func()
;
