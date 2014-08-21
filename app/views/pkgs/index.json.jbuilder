json.array!(@pkgs) do |pkg|
  json.extract! pkg, :id, :pkg, :program_id, :level
  json.url pkg_url(pkg, format: :json)
end
