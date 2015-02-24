class AddRegDate < ActiveRecord::Migration
  def up
    execute <<-SQL
ALTER TABLE students ADD COLUMN registered_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT clock_timestamp();
UPDATE students SET registered_at = created_at;
CREATE INDEX students_registered_at ON students(registered_at);

CREATE OR REPLACE FUNCTION check_registered_at()
  RETURNS TRIGGER AS $body$
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
$body$
LANGUAGE plpgsql;

CREATE TRIGGER students_check_registered_at
  BEFORE UPDATE ON students 
  FOR EACH ROW EXECUTE PROCEDURE check_registered_at()
;
SQL
  end
  
  def down
    execute <<-SQL
DROP TRIGGER IF EXISTS students_check_registered_at ON students;
SQL
    remove_column :students, :registered_at
  end
end
