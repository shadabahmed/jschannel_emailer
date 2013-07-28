require "addressable/uri"

class GithubApi
  REPOS_URL = "https://github.com/languages/%s/most_watched?page=%s"
  REPO_STARGAZERS_URL = "https://api.github.com/repos/%s/stargazers?page=%s"
  REPO_CONTRIBUTORS_URL = "https://api.github.com/repos%s/contributors"
  REPO_COLLABORATORS_URL = "https://api.github.com/repos%s/collaborators"
  USER_FOLLOWERS_URL = "https://api.github.com/users/%s/followers?page=%s"
  USER_REPOSITORIES_URL = "https://api.github.com/users/%s/repos"
  REPO_COMMITS_URL = "https://api.github.com/repos/%s/commits?author=%s"
  USER_FOLLOWING_URL = "https://api.github.com/users/%s/following?page=%s"
  USER_PROFILE_URL = "https://api.github.com/users/%s"
  MAX_RETRIES = 5

                                          1
  class << self

    def fetch_repos(lang)
      repos = [] unless block_given?
      1.upto(10) do |page|
        url = REPOS_URL%[lang, page]
        repos_html = open_with_retry(url)
        if repos_html
          parsed_html = Nokogiri::HTML(repos_html)
          repo_links = parsed_html.css('.repolist .repolist-name a')
          repo_links.each do |link|
            repo = {:url => link['href'], :name => link.text, :page => page, :language => lang}
            if block_given?
              yield repo
            else
              repos << repo
            end
          end
        else
          break
        end
      end
      repos
    end

    def fetch_users(url)
      all_users_details = [] unless block_given?
      pagewise = url.include?('page=')
      page = 1
      while pagewise || page <= 1
        users_json = open_with_retry(url%page)
        break unless users_json
        users = JSON.parse(users_json)
        break if users.empty?
        users_with_details = fetch_users_details(users)
        if block_given?
          users_with_details.in_groups_of(30).each do |users_chunk|
            yield users_chunk
          end
        else
          all_users_details += users_with_details
        end
        page += 1
      end
      all_users_details
    end

    def email_id_through_repo(user_id)
      email = nil
      repos_json = open_with_retry(USER_REPOSITORIES_URL%user_id)
      if repos_json
        repo = JSON.parse(repos_json).first
        repo_commits_json = open_with_retry(REPO_COMMITS_URL%[repo['full_name'], user_id])
        if repo_commits_json
          commits = JSON.parse(repo_commits_json)
          if !commits.empty?
            email = commits.first['commit']['author']['email']
          end
        end
      end
      email
    end

    private

    def fetch_users_details(users)
      users.inject([]) do |users_with_details, user|
        user_json = open_with_retry(USER_PROFILE_URL%user['login'])
        if user_json
          user_details = JSON.parse(user_json)
          user_details['github_id'] = user_details.delete('id')
          user_details['followers_count'] = user_details.delete('followers')
          user_details['following_count'] = user_details.delete('following')
          user_details['following_url'] = user_details['following_url'].split('{')[0]
          user_details.delete_if{|k,_| !User.column_names.include? k}
          user_details['languages'] = []
          users_with_details << user_details
        end
        users_with_details
      end
    end

    def open_with_retry(url)
      retries, body, uri = 0, nil, Addressable::URI.parse(url)
      original_query = uri.query
      uri.query_values = (uri.query_values || {}).merge :client_id => Rails.application.config.client_id, :client_secret => Rails.application.config.client_secret
      while retries < MAX_RETRIES
        begin
          log " (#{retries + 1}) #{uri.path}#{"?#{original_query}" if original_query}"
          body = open(uri).read
          break
        rescue StandardError => e
          retries += 1
          if e.io.status[0] =~ /^5\d+/
            log "Sleeping for #{fib(retries)} seconds"
            sleep fib(retries)
            retry
          else
            body = nil
            break
          end
        end
      end
      body
    end


    def fib(n)
      curr = 0
      succ = 1
      n.times do |i|
        curr, succ = succ, curr + succ
      end
      curr
    end

    def log(msg)
      Rails.logger.info "#{ActiveSupport::LogSubscriber::CYAN}Github API:#{ActiveSupport::LogSubscriber::CLEAR}#{msg}"
    end

  end

end