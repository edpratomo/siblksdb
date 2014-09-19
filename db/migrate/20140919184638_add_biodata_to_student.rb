class AddBiodataToStudent < ActiveRecord::Migration
  def up
    add_column :students, :biodata, :hstore
  end
  
  def down
    remove_column :students, :biodata
  end
end
