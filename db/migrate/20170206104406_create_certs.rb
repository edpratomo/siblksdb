class CreateCerts < ActiveRecord::Migration
  def up
    execute <<-SQL
CREATE TABLE certs(
  id SERIAL PRIMARY KEY,
  student_id INTEGER NOT NULL REFERENCES students(id),
  course_id INTEGER NOT NULL REFERENCES courses(id),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT clock_timestamp(),
  CONSTRAINT student_course_unique UNIQUE(student_id, course_id)
);
SQL
  end

  def down
    execute <<-SQL
DROP TABLE IF EXISTS certs;
SQL
  end
end
