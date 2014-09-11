json.array!(@changes) do |change|
  json.extract! change, :id, :table_name, :action_tstamp, :action, :original_data, :new_data, :query, :modified_by
  json.url change_url(change, format: :json)
end
