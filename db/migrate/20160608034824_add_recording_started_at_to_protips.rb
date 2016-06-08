class AddRecordingStartedAtToProtips < ActiveRecord::Migration
  def change
    add_column :protips, :recording_started_at, :datetime
  end
end
