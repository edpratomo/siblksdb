class CreateBooks < ActiveRecord::Migration
  def up
    create_table :books do |t|
      t.string :name
      t.timestamps
    end

    add_reference :courses, :book, foreign_key: true

    execute <<-SQL
GRANT SELECT ON TABLE books TO siblksdb_ro;
SQL
  end

  def down
    remove_reference :courses, :book, foreign_key: true

    drop_table :books
  end

end
