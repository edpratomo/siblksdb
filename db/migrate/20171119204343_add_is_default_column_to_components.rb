class AddIsDefaultColumnToComponents < ActiveRecord::Migration
  def up
    execute <<-SQL
ALTER TABLE ONLY components ADD COLUMN is_default BOOLEAN DEFAULT FALSE;

CREATE FUNCTION set_default_component() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  comp_count INTEGER;
BEGIN
  IF (TG_OP = 'UPDATE') THEN
    IF (NEW.is_default <> OLD.is_default AND NEW.is_default = TRUE) THEN
      UPDATE components SET is_default = FALSE WHERE course_id = NEW.course_id AND id <> NEW.id;
    END IF;
    RETURN NEW;
  ELSEIF (TG_OP = 'INSERT') THEN
    IF (NEW.is_default = TRUE) THEN
      UPDATE components SET is_default = FALSE WHERE course_id = NEW.course_id AND id <> NEW.id;
    END IF;
    RETURN NEW;
  ELSEIF (TG_OP = 'DELETE') THEN
    IF (OLD.is_default = TRUE) THEN
      comp_count := (SELECT COUNT(1) FROM components WHERE course_id = OLD.course_id);
      IF (comp_count = 1) THEN
        UPDATE components SET is_default = TRUE WHERE course_id = OLD.course_id;
      END IF;
    END IF;
    RETURN OLD;
  END IF;
END;
$$;

CREATE TRIGGER components_set_default AFTER INSERT OR DELETE OR UPDATE ON components FOR EACH ROW EXECUTE PROCEDURE set_default_component();
SQL

    Course.all.each do |crs|
      if crs.components.size == 1
        only_component = crs.components.first
        only_component.is_default = true
        only_component.save!
      end
    end
  end

  def down
    execute <<-SQL
DROP TRIGGER IF EXISTS components_set_default ON components;
DROP FUNCTION IF EXISTS set_default_component();
ALTER TABLE ONLY components DROP COLUMN is_default;
SQL
  end
end
