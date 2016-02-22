class BadgeSerializer < ActiveModel::Serializer
  attributes :name,
             :description,
             :created_at,
             :badge

  protected
  def badge
    ActionController::Base.helpers.asset_url("#{ASSET_HOST}#{object.path}")
  end

end
