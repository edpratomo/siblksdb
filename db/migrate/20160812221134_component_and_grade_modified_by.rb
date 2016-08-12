class ComponentAndGradeModifiedBy < ActiveRecord::Migration
  def up
    execute <<-SQL
ALTER TABLE components ADD COLUMN modified_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT clock_timestamp();
ALTER TABLE grades ADD COLUMN modified_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT clock_timestamp();

CREATE TRIGGER components_update_timestamp 
 BEFORE UPDATE ON components
  FOR EACH ROW EXECUTE PROCEDURE update_timestamp()
;

CREATE TRIGGER grades_update_userstamp 
 BEFORE INSERT OR UPDATE ON grades
  FOR EACH ROW EXECUTE PROCEDURE update_userstamp()
;

SQL
  end

  def down
    execute <<-SQL
DROP TRIGGER IF EXISTS grades_update_userstamp ON grades;
DROP TRIGGER IF EXISTS components_update_timestamp ON components;
ALTER TABLE grades DROP COLUMN modified_at;
ALTER TABLE components DROP COLUMN modified_at;
SQL
  end
end
