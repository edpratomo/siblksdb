class AddEnabledToPkgs < ActiveRecord::Migration
  def change
    execute <<-SQL
ALTER TABLE pkgs ADD COLUMN enabled BOOLEAN NOT NULL DEFAULT TRUE;
SQL
  end
end
