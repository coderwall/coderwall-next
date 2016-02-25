class Picture < ActiveRecord::Base
  mount_uploader :file, PictureUploader

  belongs_to :user
end
