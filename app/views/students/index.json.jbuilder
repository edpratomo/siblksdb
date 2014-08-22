json.array!(@students) do |student|
  json.extract! student, :id, :name, :sex, :phone, :note, :ctime, :mtime, :modified_by
  json.url student_url(student, format: :json)
end
