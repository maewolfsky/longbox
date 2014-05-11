json.array!(@series) do |series|
  json.extract! series, :id, :name, :publisher_id, :year
  json.url series_url(series, format: :json)
end
