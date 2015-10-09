class CreateGradePoint < ActiveRecord::Migration
  def up
    execute <<-SQL
-- AA Form
CREATE TABLE grade_points (
  id SERIAL PRIMARY KEY,
  instructor_id INTEGER REFERENCES instructors(id),
  students_record_id INTEGER NOT NULL REFERENCES students_records(id),
  student_id INTEGER REFERENCES students(id),
  theory FLOAT,
  practice_id INTEGER REFERENCES grades(id),
  items hstore, -- generic items
  custom_items hstore NOT NULL DEFAULT '', -- pkg-specific grades defined in pkg_grade_items
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT clock_timestamp(),
  modified_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT clock_timestamp(),
  modified_by TEXT
);

CREATE TABLE pkg_grade_items (
  id SERIAL PRIMARY KEY,
  pkg_id INTEGER REFERENCES pkgs(id), -- refers to level 1 only
  name TEXT NOT NULL,
  sequence INTEGER NOT NULL,
  -- sequence number must be unique for a given pkg
  CONSTRAINT items_sequence_unique UNIQUE(pkg_id, sequence)
);

ALTER TABLE programs ADD COLUMN head_instructor_id INTEGER REFERENCES instructors(id);
-- ALTER TABLE grades ADD COLUMN grade_point_id INTEGER REFERENCES grade_points(id);

-- MS Word
INSERT INTO pkg_grade_items(pkg_id, name, sequence) VALUES(1, 'Mengetik (WPM)', 1);
INSERT INTO pkg_grade_items(pkg_id, name, sequence) VALUES(1, 'Mengetik (ACC)', 2);
INSERT INTO pkg_grade_items(pkg_id, name, sequence) VALUES(1, 'Mengelola Dokumen', 3);
INSERT INTO pkg_grade_items(pkg_id, name, sequence) VALUES(1, 'Tabel & Grafik', 4);

-- MS Excel
INSERT INTO pkg_grade_items(pkg_id, name, sequence) VALUES(5, 'Pengolahan Formula', 1);
INSERT INTO pkg_grade_items(pkg_id, name, sequence) VALUES(5, 'Mengatur Lembar Kerja', 2);
INSERT INTO pkg_grade_items(pkg_id, name, sequence) VALUES(5, 'Grafik', 3);

CREATE OR REPLACE FUNCTION populate_grade_items()
  RETURNS TRIGGER AS $body$
BEGIN
  IF (NEW.items IS NULL) THEN
    NEW.items := '"100 Kualitas Pekerjaan"=>NULL,"110 Fisik Mental dan Disiplin (FMD) - Terlambat/Kehadiran"=>NULL' || 
                 ',"120 Motivasi Kerja"=>NULL,"130 Inisiatif & Kreativitas"=>NULL,"140 Komunikasi"=>NULL' ||
                 ',"150 Rekomendasi"=>NULL,"160 Keterangan"=>NULL';

  END IF;
  RETURN NEW;  
END;
$body$
LANGUAGE plpgsql;

CREATE TRIGGER grade_points_populate_items
 BEFORE INSERT ON grade_points
  FOR EACH ROW EXECUTE PROCEDURE populate_grade_items()
;
SQL
  end
  
  def down
    execute <<-SQL
DROP TRIGGER IF EXISTS grade_points_populate_items ON grade_points;
ALTER TABLE programs DROP COLUMN head_instructor_id;  
DROP TABLE pkg_grade_items;
DROP TABLE grade_points;
SQL
  end
end
