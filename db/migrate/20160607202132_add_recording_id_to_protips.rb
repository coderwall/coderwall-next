class AddRecordingIdToProtips < ActiveRecord::Migration
  def change
    add_column :protips, :recording_id, :text
  end
end
