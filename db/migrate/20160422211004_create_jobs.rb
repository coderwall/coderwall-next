class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.timestamps null: false
      t.string :role_type
      t.string :title
      t.string :location
      t.string :source
      t.text :description
      t.text :how_to_apply
      t.string :company
      t.string :company_url
      t.string :company_logo
      t.string :author_name
      t.string :author_email
    end
  end
end
