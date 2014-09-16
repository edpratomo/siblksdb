class CreateSettings < ActiveRecord::Migration
  def up
    execute <<-SQL
CREATE TABLE settings (
  id SERIAL PRIMARY KEY,
  config_key TEXT NOT NULL UNIQUE,
  config_value TEXT
);
    SQL
  end
  
  def down
    drop_table :settings
  end
end
