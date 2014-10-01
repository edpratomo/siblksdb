class AddTriggersToStudentsRecords < ActiveRecord::Migration
  def change
    execute <<-SQL
CREATE TRIGGER students_records_if_modified
 AFTER INSERT OR UPDATE OR DELETE ON students_records
  FOR EACH ROW EXECUTE PROCEDURE if_modified_func()
;
CREATE TRIGGER students_records_update_timestamp 
 BEFORE UPDATE ON students_records
  FOR EACH ROW EXECUTE PROCEDURE update_timestamp()
;
CREATE TRIGGER students_records_update_userstamp
 BEFORE INSERT OR UPDATE ON students_records
  FOR EACH ROW EXECUTE PROCEDURE update_userstamp()
;
SQL
  end
end
