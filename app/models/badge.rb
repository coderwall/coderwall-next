class Badge < ActiveRecord::Base
  belongs_to :user

  def path
    "badges/#{image_name}"
  end
end
