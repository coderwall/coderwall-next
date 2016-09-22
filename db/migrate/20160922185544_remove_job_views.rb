class RemoveJobViews < ActiveRecord::Migration
  def change
    drop_table :job_views
  end
end
