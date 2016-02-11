class User < ActiveRecord::Base
  include Clearance::User

  mount_uploader :avatar, AvatarUploader

  before_create :generate_unique_color

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

  def email_optional?
    true #added this hack so clereance doesn't do email validation while bulk loading
  end

  def display_name
    name.presence || username
  end

  def display_title
    "#{title} at Acme, Inc." if title
  end

  def generate_unique_color
    # ActiveSupport::SecureRandom.hex(3)
    self.color = ("#%06x" % (rand * 0xffffff))
  end

end
