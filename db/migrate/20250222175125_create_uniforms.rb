class CreateUniforms < ActiveRecord::Migration
  def up
    create_table :uniforms do |t|
      t.string :name
      t.timestamps
    end

    add_reference :courses, :uniform, foreign_key: true
  end

  def down
    remove_reference :courses, :uniform, foreign_key: true

    drop_table :uniforms
  end
end
