class User < ActiveRecord::Base
  has_and_belongs_to_many :repositories
  has_and_belongs_to_many :followers, :class_name => 'User', :join_table => 'users_followers', :association_foreign_key => :follower_id
  has_and_belongs_to_many :following, :class_name => 'User', :join_table => 'users_followers', :foreign_key => :follower_id

  serialize :languages

  def self.create_from_json(json)
    users = []
    transaction do
      json.each do |partial_user_json|
        user_url = partial_user_json['url'] + "?client_id=#{Rails.application.config.client_id}&client_secret=#{Rails.application.config.client_secret}"
        user_json_body = nil
        retries = 1
        while retries <= 5
          begin
            retries += 1
            Rails.logger.info "Tyring for #{user_url}, Attempt #{retries}"
            user_json_body = open(user_url).read
          rescue StandardError => e
            sleep 3
            retry
          end
        end
        user_json = JSON.parse(user_json_body)
        user_json['github_id'] = user_json.delete('id')
        user_json['followers_count'] = user_json.delete('followers')
        user_json['following_count'] = user_json.delete('following')
        user_json['following_url'] = user_json['following_url'].split('{')[0]
        user_json.delete_if{|k,v| !column_names.include? k}
        user_json['languages'] = []
        user = User.where(user_json).first_or_create
        users << user
      end
    end
    users
  rescue StandardError => e
    Rails.logger.info("Error creating users: #{e.message}\n#{e.backtrace}")
    nil
  end

  def crawl_followers
    api_url = followers_url + "?client_id=#{Rails.application.config.client_id}&client_secret=#{Rails.application.config.client_secret}"
    users = User.create_from_json JSON.parse open(api_url).read
    if users
      self.followers << users
      users.each do |user|
        user.languages |= self.languages
        user.save
      end
      self.update_attribute :followers_crawled, true
    end
  end

  def crawl_following
    api_url = following_url + "?client_id=#{Rails.application.config.client_id}&client_secret=#{Rails.application.config.client_secret}"
    users = User.create_from_json JSON.parse open(api_url).read
    if users
      self.following << users
      self.update_attribute :following_crawled, true
    end
  end

end
