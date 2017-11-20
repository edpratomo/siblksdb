class AddIsDefaultColumnToComponents < ActiveRecord::Migration
  def up
    execute <<-SQL
ALTER TABLE ONLY components ADD COLUMN is_default BOOLEAN DEFAULT FALSE;
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
ALTER TABLE ONLY components DROP COLUMN is_default;
SQL
  end
end
