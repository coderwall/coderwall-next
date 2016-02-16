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

  def email_optional?
    true #added this hack so clereance doesn't do email validation while bulk loading
  end

  def likes?(obj)
    likes.exists?(likable_id: obj.id, likable_type: obj.class.name)
  end

  def liked
    likes.includes(:likable).collect do |like|
      ActionView::RecordIdentifier.dom_id(like.likable)
    end
  end

  def account_age_in_days
    ((Time.now - created_at) / 60 / 60 / 24 ).floor
  end

  def display_name
    name.presence || username
  end

  def display_title
    a = [title, company].reject(&:blank?).join(' at ')
  end

  def generate_unique_color
    self.color = ("#%06x" % (rand * 0xffffff))
  end

  def can_edit?(obj)
    return true if admin? || obj == self
    return obj.user == self if obj.respond_to?(:user)
  end

  def editable_skills
    skills.join(', ')
  end

  def editable_skills=(val)
    self.skills = val.split(',').collect(&:strip)
  end

end
