class CreateCerts < ActiveRecord::Migration
  def change
    create_table :certs do |t|

      t.timestamps null: false
    end
  end
end
