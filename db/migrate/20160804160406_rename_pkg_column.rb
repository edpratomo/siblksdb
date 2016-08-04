class RenamePkgColumn < ActiveRecord::Migration
  def up
    execute <<-SQL
ALTER TABLE pkgs ALTER COLUMN pkg DROP NOT NULL;
ALTER TABLE pkgs RENAME COLUMN pkg TO pkg_old;
SQL
  end

  def down
    execute <<-SQL
ALTER TABLE pkgs RENAME COLUMN pkg_old TO pkg;
ALTER TABLE pkgs ALTER COLUMN pkg SET NOT NULL;
SQL
  end
end
