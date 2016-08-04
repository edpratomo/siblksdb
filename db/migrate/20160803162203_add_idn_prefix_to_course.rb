class AddIdnPrefixToCourse < ActiveRecord::Migration
  def up
    execute <<-SQL
ALTER TABLE courses ADD COLUMN idn_prefix TEXT NOT NULL DEFAULT '';
UPDATE courses SET idn_prefix = 'KOM' WHERE id < 9;
UPDATE courses SET idn_prefix = 'AC' WHERE id = 9;
UPDATE courses SET idn_prefix = 'LS' WHERE id = 10;
UPDATE courses SET idn_prefix = 'MB' WHERE id = 11;
UPDATE courses SET idn_prefix = 'TSM' WHERE id = 12;
UPDATE courses SET idn_prefix = 'LI' WHERE id = 13;
UPDATE courses SET idn_prefix = 'ING' WHERE id = 14;
SQL
  end

  def down
    execute <<-SQL
ALTER TABLE courses DROP COLUMN idn_prefix;
SQL
  end
end
