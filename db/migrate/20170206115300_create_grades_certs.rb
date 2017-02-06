class CreateGradesCerts < ActiveRecord::Migration
  def up
    execute <<-SQL
CREATE TABLE grades_certs(
  id SERIAL PRIMARY KEY,
  grade_id INTEGER NOT NULL REFERENCES grades(id),
  cert_id INTEGER NOT NULL REFERENCES certs(id),
  CONSTRAINT grade_cert_unique UNIQUE(grade_id, cert_id)
);
SQL
  end

  def down
    execute <<-SQL
DROP TABLE IF EXISTS grades_certs;
SQL
  end
end
