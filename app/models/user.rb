class User < ActiveRecord::Base
  has_and_belongs_to_many :repositories, :join_table =>  'repositories_contributors'
  has_and_belongs_to_many :followers, :class_name => 'User', :join_table => 'users_followers', :association_foreign_key => :follower_id
  has_and_belongs_to_many :following, :class_name => 'User', :join_table => 'users_followers', :foreign_key => :follower_id

  scope :with_uncrawled_followers, -> { where(:followers_crawled => false) }
  scope :with_uncrawled_following, -> { where(:following_crawled => false) }

  serialize :languages

  def self.create_from_json(users_params)
    users = []
    transaction do
      users_params.each do |user_params|
        user = User.where(:login => user_params['login']).first_or_create
        user.update_attributes! users_params
        users << user
      end
    end
    users
  end

  def crawl_followers
    GithubApi.fetch_users(GithubApi::USER_FOLLOWERS_URL%[self.login, '%s']) do |users_params|
      users = User.create_from_json(users_params)
      self.followers |= users
    end
    self.update_attribute :followers_crawled, true
    self.followers
  end

  def crawl_following
    GithubApi.fetch_users(GithubApi::USER_FOLLOWING_URL%[self.login, '%s']) do |users_params|
      users = User.create_from_json(users_params)
      self.following |= users
    end
    self.update_attribute :following_crawled, true
    self.following
  end

end
