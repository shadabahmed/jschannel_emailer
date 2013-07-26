class Repository < ActiveRecord::Base
  has_and_belongs_to_many :contributors, :class_name => 'User', :join_table =>  'repositories_contributors'
  has_and_belongs_to_many :collaborators, :class_name => 'User',  :join_table =>  'repositories_collaborators'

  def self.pull(language)
    repos = []
    current_page = RepoScrapeState[language].page
    Repository.destroy_all(:page => current_page, :language => language)
    repos_url = "https://github.com/languages/#{language}/most_watched?page=#{current_page}"
    transaction do
      repos_html = open(repos_url)
      html_doc = Nokogiri::HTML(repos_html.read)
      repo_links = html_doc.css('.repolist .repolist-name a')
      repo_links.each do |link|
        repos << create(:url => link['href'], :name => link.text, :page => current_page, :language => language)
      end
      RepoScrapeState[language].update_attribute :page, current_page + 1
    end
    repos
  rescue StandardError => e
    Rails.logger.info("Error creating repositories: #{e.message}\n#{e.backtrace}")
    nil
  end

  def crawl_contributors
    users = crawl contributors_url
    if users
      self.update_attribute :contributors_crawled, true
      self.contributors << users
    end
  end

  def crawl_collaborators
    users = crawl collaborators_url
    if users
      self.update_attribute :contributors_crawled, true
      self.collaborators << users
    end
  end

  private

  def crawl(api_url)
    Rails.logger.info "Opening #{api_url}"
    users_json = JSON.parse(open(api_url).read)
    users = User.create_from_json(users_json)
    users.each do |contributor|
      contributor.languages ||= []
      contributor.languages << self.language if !user.contributor.include?(self.language)
      contributor.save
    end
    users
  end

  def collaborators_url
    "https://api.github.com/repos#{url}/collaborators?client_id=#{Rails.application.config.client_id}&client_secret=#{Rails.application.config.client_secret}"
  end

  def contributors_url
    "https://api.github.com/repos#{url}/contributors?client_id=#{Rails.application.config.client_id}&client_secret=#{Rails.application.config.client_secret}"
  end
end
