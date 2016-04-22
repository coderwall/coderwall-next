class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.timestamps null: false
      t.string :type
      t.string :title
      t.string :location
      t.text :description
      t.text :how_to_apply
      t.string :company_name
      t.string :company_website
      t.string :company_logo
    end
  end
end
