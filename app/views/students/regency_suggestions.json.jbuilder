json.array!(@regencies) do |s|
  json.extract! s, :name, :id
end
