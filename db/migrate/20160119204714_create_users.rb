class CreateUsers < ActiveRecord::Migration
  def up
    enable_extension("citext")

    create_table :users do |t|
      t.string :name, :avatar, :title, :location, :country, :city, :state_name
      t.string :company
      t.text :about
      t.integer :team_id
      t.string  :api_key
      t.boolean :admin
      t.boolean :receive_newsletter,    default: true
      t.boolean :receive_weekly_digest, default: true
      t.integer :login_count
      t.integer :last_ip
      t.timestamp :banned_at
      t.timestamp :last_email_sent, :last_request_at
      t.timestamps null: false
    end

    add_column :users, :username, :citext
    add_column :users, :email, :citext
  end

  def down
    drop_table :users
  end
end
