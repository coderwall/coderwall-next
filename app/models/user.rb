class User < ActiveRecord::Base
  include Clearance::User

  mount_uploader :avatar, AvatarUploader

  has_many :likes,    dependent: :destroy
  has_many :protips,  dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :badges,   dependent: :destroy


  RESERVED = %w{
    achievements
    admin
    administrator
    api
    contact_us
    emails
    faq
    privacy_policy
    root
    superuser
    teams
    tos
    usernames
    users
  }

  VALID_USERNAME_RIGHT_WAY = /\A[a-z0-9]+\z/
  VALID_USERNAME           = /\A[^\.]+\z/

  validates :username,
            exclusion: {in: RESERVED, message: "is reserved"},
            format:    {with: VALID_USERNAME, message: "must not contain a period"},
            uniqueness: true,
            if: :username_changed?

  validates_presence_of :username
  validates_presence_of :email


  def to_param
    username.downcase
  end

  def display_name
    name.presence || username
  end

  def color
    # 303544
    # ActiveSupport::SecureRandom.hex(3)
    @color ||= ("#%06x" % (rand * 0xffffff))
  end

end
