json.array!(@students) do |student|
  json.extract! student, :id, :name, :sex, :birthplace, :birthdate, :phone, :note, :created_at, :modified_at, :modified_by
  json.url student_url(student, format: :json)
end
