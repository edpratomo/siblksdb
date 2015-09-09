json.array!(@grade_sheets) do |grade_sheet|
  json.extract! grade_sheet, :id
  json.url grade_sheet_url(grade_sheet, format: :json)
end
