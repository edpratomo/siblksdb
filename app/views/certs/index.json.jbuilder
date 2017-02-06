json.array!(@certs) do |cert|
  json.extract! cert, :id
  json.url cert_url(cert, format: :json)
end
