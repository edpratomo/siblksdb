# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

if Uniform.count == 0
  uniform_teknik = Uniform.create(name: "Teknik")
  uniform_bengkel = Uniform.create(name: "Bengkel Sepeda Motor")
  uniform_blk = Uniform.create(name: "BLK")

  Course.update_all(uniform_id: uniform_blk)
  Course.where("name LIKE ?", "Sepeda Motor%").update_all(uniform_id: uniform_bengkel)
  Course.where("name LIKE ?", "Las%").update_all(uniform_id: uniform_teknik)
  Course.where("name LIKE ?", "Mekanik%").update_all(uniform_id: uniform_teknik)
end
