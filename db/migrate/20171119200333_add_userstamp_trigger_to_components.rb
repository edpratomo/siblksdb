class AddUserstampTriggerToComponents < ActiveRecord::Migration
  def up
    execute <<-SQL
CREATE TRIGGER components_update_userstamp BEFORE INSERT OR UPDATE ON components FOR EACH ROW EXECUTE PROCEDURE update_userstamp();
SQL
  end

  def down
    execute <<-SQL
DROP TRIGGER components_update_userstamp ON components;
SQL
  end
end
