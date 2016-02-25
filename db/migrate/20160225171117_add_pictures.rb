class AddPictures < ActiveRecord::Migration
  def up
    create_table :pictures do |t|
      t.integer :user_id
      t.string :file
      t.timestamps
    end

    add_index :pictures, :user_id, unique: false
  end

  def down
    drop_table :pictures
  end
end
