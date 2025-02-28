class AddForeignTables < ActiveRecord::Migration
  def up
    rails_env = ENV['RAILS_ENV'] || 'development'
    db_suffix = if rails_env == "development"
      "dev"
    elsif rails_env == "production"
      "prod"
    else
      rails_env
    end
    siblksdb_ro_password = ENV['SIBLKSDB_RO_PASSWORD']

    execute <<-SQL
CREATE EXTENSION IF NOT EXISTS "postgres_fdw";

CREATE SERVER v2server_#{db_suffix} FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host '127.0.0.1', dbname 'siblksdb_v2_#{db_suffix}');
CREATE USER MAPPING FOR siblksdb SERVER v2server_#{db_suffix} OPTIONS (user 'siblksdb_ro', password '#{siblksdb_ro_password}');
CREATE SCHEMA IF NOT EXISTS siblksdb_v2;
IMPORT FOREIGN SCHEMA public EXCEPT (ar_internal_metadata, schema_migrations) FROM SERVER v2server_#{db_suffix} INTO siblksdb_v2;
ALTER DATABASE siblksdb_#{db_suffix} SET SEARCH_PATH TO public;
SET SEARCH_PATH TO public;
SQL
  end

  def down
    rails_env = ENV['RAILS_ENV'] || 'development'
    db_suffix = if rails_env == "development"
      "dev"
    elsif rails_env == "production"
      "prod"
    else
      rails_env
    end

    execute <<-SQL
DROP SERVER v2server_#{db_suffix} CASCADE
SQL
  end
end
