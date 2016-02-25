class PictureSerializer < ActiveModel::Serializer
  attributes :name,
             :type,
             :created_at,
             :url

  protected
  def name
    object.file.file.filename
  end

  def type
    object.file.file.extension.downcase
  end

  def url
    object.file.url
  end
end
