class CreateUsersInstructors < ActiveRecord::Migration
  def up
    execute <<-SQL
CREATE TABLE users_instructors (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  instructor_id INTEGER REFERENCES instructors(id),
  CONSTRAINT user_instructor_unique UNIQUE(user_id, instructor_id)
);
SQL
    # Note that "create_join_table" generates invalid SQL:
    # PG::SyntaxError: ERROR:  zero-length delimited identifier at or near """"
    # LINE 1: ...ET "instructor_id" = $1 WHERE "users_instructors"."" IS NULL
    #
    # http://stackoverflow.com/questions/23165282/error-zero-length-delimited-identifier-at-or-near-line-1-delete-from-reg
    #
    # create_join_table(:users, :instructors, table_name: :users_instructors) do |t|
    #   t.index [:user_id, :instructor_id] unique: true,
    #   t.index [:instructor_id, :user_id] unique: true
    # end

    Group.new(name: "instructor").save!
  end

  def down
    drop_join_table :users, :instructors, table_name: :users_instructors
    Group.find_by(name: "instructor").delete
  end
end
