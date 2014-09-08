class InitializeInstructorsSchedulesFunction < ActiveRecord::Migration
  def change
    execute <<-SQL
CREATE OR REPLACE FUNCTION initialize_instructors_schedules(v_instructor_id INTEGER)
  RETURNS INTEGER AS $$
DECLARE
  sched_rec RECORD;
  dayv      TEXT;
  days      TEXT[] := ARRAY['mon', 'tue', 'wed', 'thu', 'fri', 'sat'];
BEGIN
    FOR sched_rec IN SELECT id, label FROM schedules LOOP
      FOREACH dayv IN ARRAY days LOOP
        IF NOT (dayv = 'wed' AND (sched_rec.label = 'Jam ke-4' OR sched_rec.label = 'Jam ke-5')) THEN
          INSERT INTO instructors_schedules (instructor_id, schedule_id, day) VALUES (v_instructor_id, sched_rec.id, dayv);
        END IF;
      END LOOP;
    END LOOP;
  RETURN 1;
END;
$$ LANGUAGE 'plpgsql';
    SQL
  end
end
