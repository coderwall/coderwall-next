class CreateProtips < ActiveRecord::Migration

  # Omitted
  #  kind                :string(255)
  #  created_by          :string(255)      default("self")
  #  featured            :boolean          default(FALSE)
  #  upvotes_value_cache :integer          default(0), not null
  #  inappropriate       :integer          default(0)
  #  likes_count         :integer          default(0)
  #  user_name           :string(255)
  #  user_email          :string(255)
  #  user_agent          :string(255)
  #  user_ip             :inet
  #  spam_reports_count  :integer          default(0)
  #  state               :string(255)      default("active")

  def change
    create_table :protips do |t|
      t.string :public_id, :title, :slug
      t.text :body
      t.integer :user_id
      t.float   :score, :boost_factor
      t.timestamp :featured_at
      t.timestamps null: false
    end
  end
end
