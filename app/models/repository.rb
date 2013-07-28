class Repository < ActiveRecord::Base
  has_and_belongs_to_many :contributors, :class_name => 'User', :join_table =>  'repositories_contributors'
  has_and_belongs_to_many :collaborators, :class_name => 'User',  :join_table =>  'repositories_collaborators'

  scope :with_uncrawled_contributors, -> { where(:contributors_crawled => false) }
  scope :with_uncrawled_collaborators, -> { where(:collaborators_crawled => false) }
  scope :with_uncrawled_stargazers, -> { where(:stargazers_crawled => false) }

  def self.pull(language)
    repos = []
    GithubApi.fetch_repos(language) do |repo_params|
      repos << Repository.where(repo_params).first_or_create
    end
    repos
  end

  def crawl_contributors
    GithubApi.fetch_users(GithubApi::REPO_CONTRIBUTORS_URL%[self.url]) do |users_params|
      users = User.create_from_json(users_params)
      self.contributors << users
    end
    self.update_attribute :contributors_crawled, true
    self.contributors
  end

  def crawl_collaborators
    GithubApi.fetch_users(GithubApi::REPO_COLLABORATORS_URL%[self.url]) do |users_params|
      users = User.create_from_json(users_params)
      self.collaborators << users
    end
    self.update_attribute :collaborators_crawled, true
    self.collaborators
  end
end
