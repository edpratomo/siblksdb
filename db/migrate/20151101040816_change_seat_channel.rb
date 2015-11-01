class ChangeSeatChannel < ActiveRecord::Migration
  def change
    execute <<-SQL
CREATE OR REPLACE FUNCTION if_avail_seat_change()
  RETURNS TRIGGER AS $body$
DECLARE
  channel_suffix TEXT;
BEGIN
  channel_suffix := (SELECT SUBSTRING((SELECT current_catalog) FROM '_(.+)$'));
  PERFORM redispub('seat_' || channel_suffix, NEW.id::TEXT || '_' || NEW.avail_seat::TEXT);
  RETURN NEW;
END;
$body$
LANGUAGE plpgsql;
SQL
  end
end
