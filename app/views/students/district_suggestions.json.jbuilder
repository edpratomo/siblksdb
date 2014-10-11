json.array!(@districts) do |s|
  json.extract! s, :name, :id
end
