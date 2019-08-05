class StudentUniqueName < ActiveRecord::Migration
  def up
    execute <<-SQL
ALTER TABLE students ADD COLUMN uniq_name TEXT UNIQUE;

CREATE FUNCTION insert_uniq_name() RETURNS trigger
  LANGUAGE plpgsql
  AS $$
DECLARE
  n TEXT;
  c TEXT := 'students_uniq_name_key';
BEGIN
  UPDATE students SET uniq_name = NEW.name WHERE id = NEW.id;
  RETURN NEW;
EXCEPTION
  WHEN UNIQUE_VIOLATION THEN
    GET STACKED DIAGNOSTICS n := CONSTRAINT_NAME;
    IF n = c THEN
      UPDATE students SET uniq_name = NEW.name || ' (id:' || NEW.id::TEXT || ')' WHERE id = NEW.id;
      RETURN NEW;
    ELSE
      RAISE;
    END IF;
END;
$$;

CREATE FUNCTION update_uniq_name() RETURNS trigger
  LANGUAGE plpgsql
  AS $$
DECLARE
  is_found INTEGER;
BEGIN
  IF OLD.name <> NEW.name OR OLD.uniq_name IS NULL THEN
    is_found := (SELECT COUNT(1) FROM students WHERE name = NEW.name AND id <> NEW.id);
    IF (is_found >= 1) THEN
      NEW.uniq_name := NEW.name || ' (id:' || NEW.id::TEXT || ')';
    ELSE
      NEW.uniq_name := NEW.name;
    END IF;
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER students_insert_uniq_name AFTER INSERT ON students FOR EACH ROW EXECUTE PROCEDURE insert_uniq_name();
CREATE TRIGGER students_update_uniq_name BEFORE UPDATE ON students FOR EACH ROW EXECUTE PROCEDURE update_uniq_name();

ALTER TABLE students DISABLE TRIGGER students_check_registered_at;
UPDATE students SET uniq_name = '';
ALTER TABLE students ENABLE TRIGGER students_check_registered_at;
SQL
  end

  def down
    execute <<-SQL
DROP TRIGGER students_update_uniq_name ON students;
DROP TRIGGER students_insert_uniq_name ON students;
DROP FUNCTION IF EXISTS update_uniq_name();
DROP FUNCTION IF EXISTS insert_uniq_name();
ALTER TABLE students DROP COLUMN uniq_name;
SQL
  end
end
