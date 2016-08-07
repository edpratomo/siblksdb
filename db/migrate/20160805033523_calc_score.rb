class CalcScore < ActiveRecord::Migration
  def up
    execute <<-SQL
ALTER TABLE grades RENAME COLUMN value TO score;
ALTER TABLE grades ADD COLUMN avg_practice FLOAT NOT NULL DEFAULT 0;
ALTER TABLE grades ADD COLUMN avg_theory FLOAT NOT NULL DEFAULT 0;
SQL
  end

  def down
    execute <<-SQL
ALTER TABLE grades DROP COLUMN avg_practice;
ALTER TABLE grades DROP COLUMN avg_theory;
ALTER TABLE grades RENAME COLUMN score TO value;    
SQL
  end
end
