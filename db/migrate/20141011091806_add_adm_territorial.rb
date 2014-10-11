class AddAdmTerritorial < ActiveRecord::Migration
  def change
    files = %w(adm_territorial.sql adm_territorial_data.sql adm_territorial_foreign_key.sql)
    files.each do |fn|
      execute File.read(File.join(Rails.root, "db", fn))
    end
  end
end
