class CreateRepositoriesCollaborators < ActiveRecord::Migration
  def change
    create_table :repositories_collaborators, :id => false do |t|
      t.references :repository, index: true
      t.references :user, index: true
    end
  end
end
