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

if Book.count == 0
  diktat_tsm = Book.create(name: "Diktat TSM")
  diktat_bubut = Book.create(name: "Diktat Bubut")
  diktat_las = Book.create(name: "Diktat Las")
  diktat_ac_listrik = Book.create(name: "Diktat AC & Listrik")
  modul_ms_word = Book.create(name: "Modul MS Word")
  modul_ms_excel = Book.create(name: "Modul MS Excel")
  modul_ms_access = Book.create(name: "Modul MS Access")
  modul_ms_powerpoint = Book.create(name: "Modul MS Powerpoint")
  modul_coreldraw = Book.create(name: "Modul Coreldraw")
  modul_photoshop = Book.create(name: "Modul Photoshop")
  modul_autocad_2d = Book.create(name: "Modul Autocad 2D")
  modul_eng_introduction = Book.create(name: "Modul English - Introduction")
  modul_eng_elementary = Book.create(name: "Modul English - Elementary")
  modul_eng_intermediate = Book.create(name: "Modul English - Intermediate")
  modul_eng_advanced = Book.create(name: "Modul English - Advanced")
  modul_jahit = Book.create(name: "Modul Jahit")

  Course.where("name LIKE ?", "Sepeda Motor%").update_all(book_id: diktat_tsm)
  Course.where("name LIKE ?", "Mekanik Bubut%").update_all(book_id: diktat_bubut)

  Course.where("name LIKE ?", "Las%").update_all(book_id: diktat_las)
  Course.where("name LIKE ?", "%LAS%").update_all(book_id: diktat_las)

  Course.where("name LIKE ?", "Listrik%").update_all(book_id: diktat_ac_listrik)
  Course.where("name LIKE ?", "AC").update_all(book_id: diktat_ac_listrik)
  
  Course.where("name ILIKE ?","%Word%").update_all(book_id: modul_ms_word)
  Course.where("name ILIKE ?", "%Excel%").update_all(book_id: modul_ms_excel)
  Course.where("name ILIKE ?", "%Access%").update_all(book_id: modul_ms_access)
  Course.where("name ILIKE ?", "%PowerPoint%").update_all(book_id: modul_ms_powerpoint)
  Course.where("name ILIKE ?", "Corel%").update_all(book_id: modul_coreldraw)
  Course.where("name ILIKE ?", "%Photoshop%").update_all(book_id: modul_photoshop)
  Course.where("name ILIKE ?", "%AutoCAD 2D%").update_all(book_id: modul_autocad_2d)
  
  Course.where("name LIKE ?", "%Introduction%").update_all(book_id: modul_eng_introduction)
  Course.where("name ILIKE ?", "%Elementary%").update_all(book_id: modul_eng_elementary)
  Course.where("name ILIKE ?", "%Intermediate%").update_all(book_id: modul_eng_intermediate)
  Course.where("name ILIKE ?", "%Advanced%").update_all(book_id: modul_eng_advanced)
  
  Course.where("name ILIKE ?", "%Jahit%").update_all(book_id: modul_jahit)
end
