class AddFlaggedToProtip < ActiveRecord::Migration
  def change
    add_column :protips, :flagged, :boolean, default: false
    remove_column :protips, :boost_factor
  end
end
