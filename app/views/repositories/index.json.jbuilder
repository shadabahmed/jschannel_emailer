json.array!(@repositories) do |repository|
  json.extract! repository, :name, :url, :crawled
  json.url repository_url(repository, format: :json)
end
