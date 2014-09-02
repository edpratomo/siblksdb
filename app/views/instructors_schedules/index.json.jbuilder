json.array!(@instructors_schedules) do |instructors_schedule|
  json.extract! instructors_schedule, :id, :schedule_id, :instructor_id, :day, :avail_seat
  json.url instructors_schedule_url(instructors_schedule, format: :json)
end
