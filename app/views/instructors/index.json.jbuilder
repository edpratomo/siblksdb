json.array!(@instructors) do |instructor|
  json.extract! instructor, :id, :name, :modified_at, :modified_by
  json.url instructor_url(instructor, format: :json)
end
