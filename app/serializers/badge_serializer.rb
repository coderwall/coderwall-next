class BadgeSerializer < ActiveModel::Serializer
  attributes :name,
             :description,
             :created_at,
             :badge

  protected
  def badge
    ActionController::Base.helpers.asset_path(object.path)
  end

end
