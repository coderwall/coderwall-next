class AddTagsAndCountColumns < ActiveRecord::Migration
  def change

    change_table :protips do |t|
      t.string :tags, array: true, default: []
      t.integer :likes_count, default: 0
      t.integer :views_count, default: 0
    end

    add_index  :protips, :tags, using: 'gin'

    change_table :users do |t|
      t.string :skills, array: true, default: []
      t.string  :github_id, :twitter_id, :github, :twitter
    end

    add_index  :users, :skills, using: 'gin'

  end
end
