json.array!(@publishers) do |publisher|
  json.extract! publisher, :id, :name
  json.url publisher_url(publisher, format: :json)
end
