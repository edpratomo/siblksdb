class AddHeadInstructor < ActiveRecord::Migration
  def change
    execute <<-SQL
    ALTER TABLE programs ADD COLUMN head_instructor INTEGER REFERENCES instructors(id);
SQL
  end
end
