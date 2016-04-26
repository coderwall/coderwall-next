class CreateJobViews < ActiveRecord::Migration
  def change
    create_table :job_views do |t|
      # required
      t.datetime :created_at, null: false
      t.uuid     :job_id,     null: false

      # optional
      t.integer :user_id
      t.text :ip

      t.foreign_key :jobs
      t.foreign_key :users
    end
  end
end
