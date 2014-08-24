json.array!(@suggestions) do |s|
  json.extract! s, :name, :id, :birthplace, :birthdate
end
