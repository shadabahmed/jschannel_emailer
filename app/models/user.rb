class User < ActiveRecord::Base
  has_and_belongs_to_many :repositories
  serialize :languages

  def self.create_from_json(json)
    users = []
    transaction do
      json.each do |partial_user_json|
        user_json = JSON.parse(open(partial_user_json['url']).read)
        user_json['github_id'] = user_json.delete('id')
        user_json.delete_if{|k,v| !column_names.include? k}
        user = User.where(user_json).first_or_create
        users << user
      end
    end
    users
  rescue StandardError => e
    Rails.logger.info("Error creating users: #{e.message}\n#{e.backtrace}")
    []
  end

end
