class CreateRepositories < ActiveRecord::Migration
  def change
    create_table :repositories do |t|
      t.string :name
      t.string :url
      t.boolean :contributors_crawled, :default => false
      t.boolean :collaborators_crawled, :default => false
      t.integer :page
      t.string :language
      t.timestamps
    end
  end
end
