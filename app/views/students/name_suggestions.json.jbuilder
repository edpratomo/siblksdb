json.array!(@suggestions) do |s|
  json.extract! s, :name, :id, :birthplace, :birthdate
  json.local_birthdate(s.birthdate.strftime('%d/%m/%Y'))
end
