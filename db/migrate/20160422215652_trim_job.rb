class TrimJob < ActiveRecord::Migration
  def change
    remove_column :jobs, :description
    remove_column :jobs, :how_to_apply    
  end
end
