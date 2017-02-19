class Picture < ApplicationRecord
  mount_uploader :file, PictureUploader

  belongs_to :user, required: true
end
