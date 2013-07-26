class CreateRepositoriesContributors < ActiveRecord::Migration
  def change
    create_table :repositories_contributors, :id => false do |t|
      t.references :repository, :index => true
      t.references :user, :index => true
    end
  end
end
