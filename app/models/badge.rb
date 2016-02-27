class Badge < ActiveRecord::Base
  belongs_to :user, required: true

  def path
    "badges/#{image_name}"
  end
end
