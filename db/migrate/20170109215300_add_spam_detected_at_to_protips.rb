class AddSpamDetectedAtToProtips < ActiveRecord::Migration
  def change
    add_column :protips, :spam_detected_at, :datetime
  end
end
