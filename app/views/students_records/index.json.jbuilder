json.array!(@students_records) do |students_record|
  json.extract! students_record, :id, :student_id, :pkg_id, :started_on, :finished_on, :status, :modified_at, :modified_by
  json.url students_record_url(students_record, format: :json)
end
