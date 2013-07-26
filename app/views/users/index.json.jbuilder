json.array!(@users) do |user|
  json.extract! user, :login, :github_id, :avatar_url, :url, :html_url, :followers_url, :following_url, :starred_url, :organizations_url, :repos_url, :type
  json.url user_url(user, format: :json)
end
