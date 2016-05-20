class AddTypeToProtips < ActiveRecord::Migration
  def up
    add_column :protips, :type, :text
    Protip.update_all(type: Protip.name)
    change_column :protips, :type, :text, null: false
    add_index :protips, :type
  end

  def down
    remove_column :protips, :type, :text
  end
end
