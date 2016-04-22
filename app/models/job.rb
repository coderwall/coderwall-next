class Job < ActiveRecord::Base

  scope :active, -> { where("created_at >= ?", 1.month.ago) }
end
