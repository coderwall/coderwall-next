class AddColorToUser < ActiveRecord::Migration
  def change
    add_column :users, :color, :string, default: '#111'
  end
end
