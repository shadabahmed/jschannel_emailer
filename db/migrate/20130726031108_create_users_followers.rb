class CreateUsersFollowers < ActiveRecord::Migration
  def change
    create_table :users_followers, :id => false do |t|
      t.references :user
      t.references :follower
    end
  end
end
