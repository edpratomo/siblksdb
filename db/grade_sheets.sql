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

-- komponen-komponen nilai
CREATE TABLE grade_components (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('ExamGradeComponent','PkgGradeComponent','AnyPkgGradeComponent')), -- STI
  structure TEXT NOT NULL DEFAULT '',
  annotation TEXT,
  expired_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT clock_timestamp(),
  modified_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT clock_timestamp(),
  modified_by TEXT,
  published_at TIMESTAMP WITH TIME ZONE,   -- for ExamGrade
  published_by TEXT,                       -- for ExamGrade
  pkg_id INTEGER REFERENCES pkgs(id),      -- for ExamGrade
  course_id INTEGER REFERENCES courses(id) -- for PkgGrade
);

-- a published exam is read-only, since it is attached to students_records which is permanent.
-- as long as published_by is NULL, an exam is read/write
CREATE TABLE exams(
  id SERIAL PRIMARY KEY,
  pkg_id INTEGER REFERENCES pkgs(id),
  name TEXT NOT NULL DEFAULT 'Generic',
  grade_component_id INTEGER REFERENCES grade_components(id),
  published_at TIMESTAMP WITH TIME ZONE,
  published_by TEXT,
  CONSTRAINT exam_unique UNIQUE(id, grade_component_id)
);

CREATE TABLE grades (
  id SERIAL PRIMARY KEY,
  instructor_id INTEGER REFERENCES instructors(id),
  students_record_id INTEGER NOT NULL REFERENCES students_records(id),
  student_id INTEGER REFERENCES students(id),
  anypkg_grade hstore NOT NULL DEFAULT '', -- universal components which exist in any pkg
  pkg_grade hstore NOT NULL DEFAULT '',    -- pkg-specific - defined in grade_components
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT clock_timestamp(),
  modified_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT clock_timestamp(),
  modified_by TEXT
  -- no repeated / duplicate exam for the same students_record
  -- CONSTRAINT record_exam_unique UNIQUE(students_record_id, exam_id)
);

CREATE TABLE repeatable_grades (
  id SERIAL PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT clock_timestamp(),
  modified_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT clock_timestamp(),
  modified_by TEXT,
  type TEXT NOT NULL CHECK (type IN ('ExamGrade','TheoryGrade')), -- STI
  students_record_id INTEGER NOT NULL REFERENCES students_records(id),
  grade_sum FLOAT,
  grade_id INTEGER REFERENCES grades(id),
  -- the following are specific to ExamGrade:
  exam_id INTEGER REFERENCES exams(id),
  exam_grade hstore DEFAULT ''   -- exam grade - defined in grade_components
);

INSERT INTO grade_components(pkg_id, type, name, structure) VALUES(1, 'ExamGradeComponent', 'set komponen nilai MS Word level 1',
'[{"group":"Paragraf","members":[{"component":"Indentasi","scale":10},{"component":"Perataan Teks","scale":5},{"component":"Jarak Baris","scale":7.5},{"component":"Highlight","scale":5}]},{"group":"Gambar","members":[{"component":"Simbol","scale":5},{"component":"Text Wrap","scale":10},{"component":"Image Control","scale":5}]},{"group":"Page Setup","members":[{"component":"Margins","scale":5},{"component":"Paper Size","scale":5},{"component":"Effect","scale":10}]},{"group":"Format Font","members":[{"component":"Posisi Karakter","scale":10},{"component":"Spasi Karakter","scale":10}]},{"group":"","members":[{"component":"Header dan Footer","scale":7.5},{"component":"Ketelitian dan Kerapihan","scale":5}]}]');

INSERT INTO grade_components(course_id, type, name, structure) VALUES(1, 'PkgGradeComponent', 'set komponen nilai MS Word semua level',
'[{"component":"Mengetik (WPM)"},{"component":"Mengetik (ACC)"},{"component":"Mengelola Dokumen"},{"component":"Tabel & Grafik"}]');

INSERT INTO grade_components(course_id, type, name, structure) VALUES(1, 'PkgGradeComponent', 'set komponen nilai MS Excel semua level',
'[{"component":"Pengolahan Formula"},{"component":"Mengatur Lembar Kerja"},{"component":"Grafik"}]');

INSERT INTO grade_components(course_id, type, name, structure) VALUES(1, 'AnyPkgGradeComponent', 'set komponen generik',
'[{"group":"Nilai","members":[{"component":"Teori"},{"component":"Praktek"}]},{"component":"Kualitas Pekerjaan"},{"component":"Fisik Mental dan Disiplin (FMD) - Terlambat/Kehadiran"},{"component":"Motivasi Kerja"},{"component":"Inisiatif & Kreativitas"},{"component":"Komunikasi"},{"component":"Rekomendasi"},{"component":"Keterangan"}]');

INSERT INTO exams(pkg_id, name, grade_component_id) VALUES(1, 'Obesitas', 1);
-- the following shares the same components:
INSERT INTO exams(pkg_id, name, grade_component_id) VALUES(1, 'Mata', 1);

-- publish all exams
UPDATE exams SET published_at = '2015-09-09', published_by = 'homer';
