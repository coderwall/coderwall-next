class CreateTeam < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.string :name
      t.string :avatar
      t.citext :slug
      t.string :website, :twitter, :facebook, :github
      t.string :youtube_url, :blog_feed
      t.string :location
      t.text   :about
      t.string :color
      t.timestamps
    end
  end
end
