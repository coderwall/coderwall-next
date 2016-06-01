class AddStartedArchivedFieldsToArticles < ActiveRecord::Migration
  def change
    add_column :protips, :published_at, :datetime
    add_column :protips, :archived_at, :datetime
    add_column :protips, :save_recording, :bool
  end
end
