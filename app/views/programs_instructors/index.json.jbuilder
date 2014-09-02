json.array!(@programs_instructors) do |programs_instructor|
  json.extract! programs_instructor, :id, :program_id, :instructor_id
  json.url programs_instructor_url(programs_instructor, format: :json)
end
