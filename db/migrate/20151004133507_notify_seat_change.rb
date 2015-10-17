class NotifySeatChange < ActiveRecord::Migration
  def up
    execute <<-SQL
CREATE EXTENSION IF NOT EXISTS "pg_redispub";

CREATE OR REPLACE FUNCTION if_avail_seat_change()
  RETURNS TRIGGER AS $body$
BEGIN
  PERFORM redispub('seat', NEW.id::TEXT || '_' || NEW.avail_seat::TEXT);
  RETURN NEW;
END;
$body$
LANGUAGE plpgsql;

CREATE TRIGGER instructors_schedules_seat_change
 AFTER UPDATE OF avail_seat ON instructors_schedules
  FOR EACH ROW EXECUTE PROCEDURE if_avail_seat_change()
;
SQL
  end

  def down
    execute <<-SQL
DROP TRIGGER IF EXISTS instructors_schedules_seat_change ON instructors_schedules;
SQL
  end
end
