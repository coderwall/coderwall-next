class UserSerializer < ActiveModel::Serializer
  has_many   :badges
  attributes :username,
             :name,
             :location,
             :karma,
             :accounts,
             :about,
             :title,
             :company,
             :team,
             :thumbnail,
             :endorsements,
             :specialities

  protected
  def team
    object.team_id
  end

  #backwords compatibility
  def specialities
    []
  end

  #backwords compatibility
  def endorsements
    karma
  end

  def accounts
    { github: object.github, twitter: object.twitter }
  end

  def thumbnail
    object.avatar.url
  end

end
