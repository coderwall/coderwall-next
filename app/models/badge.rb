class Badge < ApplicationRecord
  belongs_to :user, required: true

  def path
    "badges/#{image_name}"
  end
end
