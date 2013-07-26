class CreateRepoScrapeStates < ActiveRecord::Migration
  def change
    create_table :repo_scrape_states do |t|
      t.string :language
      t.integer :page, :default => 1
      t.timestamps
    end
  end
end
