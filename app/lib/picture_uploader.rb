class PictureUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  process :auto_orient

  def auto_orient
    manipulate! do |image|
      image.collapse!
      image.auto_orient
      image
    end
  end

  def extension_white_list
    %w(jpg jpeg gif png psd pdf)
  end

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

end
