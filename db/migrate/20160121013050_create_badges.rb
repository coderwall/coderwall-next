class CreateBadges < ActiveRecord::Migration
  def change
    create_table :badges do |t|
      t.integer :user_id
      t.string  :name, :description, :why, :image_name, :provider
      t.timestamps null: false
    end
  end
end
