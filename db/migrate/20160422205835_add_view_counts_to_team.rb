class AddViewCountsToTeam < ActiveRecord::Migration
  def change
    add_column "teams", "views_count", :integer, default: 0
  end
end
