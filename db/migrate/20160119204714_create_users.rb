class CreateUsers < ActiveRecord::Migration
  def up
    enable_extension("citext")

    create_table :users do |t|
      t.string :name, :avatar, :title, :location, :country, :city, :state_name
      t.text :about
      t.boolean :admin
      t.integer :login_count
      t.timestamp :banned_at
      t.timestamps null: false
    end

    add_column :users, :username, :citext
    add_column :users, :email, :citext
  end

  def down
    drop_table :users
  end
end
