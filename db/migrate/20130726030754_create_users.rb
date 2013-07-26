class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :login
      t.integer :github_id
      t.text :avatar_url
      t.string :url
      t.string :html_url
      t.string :followers_url
      t.string :following_url
      t.string :starred_url
      t.string :organizations_url
      t.string :repos_url
      t.string :type
      t.string :name
      t.string :company
      t.string :blog
      t.string :location
      t.string :email
      t.string :bio
      t.integer :public_repos
      t.integer :followers
      t.integer :following
      t.boolean :crawled, :default => false
      t.text :languages
      t.timestamps
    end
  end
end
