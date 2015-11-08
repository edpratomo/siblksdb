class AddHeadInstructor < ActiveRecord::Migration
  def change
    ALTER TABLE programs ADD COLUMN head_instructor INTEGER REFERENCES instructors(id);
  end
end
