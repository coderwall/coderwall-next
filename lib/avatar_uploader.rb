class AvatarUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  process resize_and_pad: [100, 100]
  # storage :fog

  def default_url
    model_name = model.class.name.downcase
    ActionController::Base.helpers.asset_path "#{model_name}-avatar.png"
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

end
