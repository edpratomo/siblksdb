class ModifyCheckInstructorProgram < ActiveRecord::Migration
  def change
    execute <<-SQL
CREATE OR REPLACE FUNCTION check_instructors_program()
  RETURNS TRIGGER AS $body$
DECLARE
  is_found   INTEGER;
BEGIN
  is_found := (SELECT COUNT(1) FROM students_pkgs sp 
                                    JOIN pkgs ON sp.pkg_id = pkgs.id 
                                    JOIN courses ON courses.id = pkgs.course_id
                                    JOIN programs_instructors prins ON prins.program_id = courses.program_id
                                    JOIN instructors ins ON ins.id = prins.instructor_id
                                    JOIN instructors_schedules insch ON insch.instructor_id = ins.id
               WHERE sp.id = NEW.students_pkg_id AND insch.id = NEW.instructors_schedule_id);
  IF NOT (is_found = 1) THEN
    RAISE EXCEPTION '[CHECK_INSTRUCTORS_PROGRAM] - instructor does not match program';
    RETURN NULL;
  ELSE
    RETURN NEW;
  END IF;
END;
$body$
LANGUAGE plpgsql;
SQL
  end
end
