json.array!(@schedules) do |schedule|
  json.extract! schedule, :id, :label, :time_slot
  json.url schedule_url(schedule, format: :json)
end
