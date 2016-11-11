class User < ActiveRecord::Base
  include Clearance::User

  html_schema_type :Person
  mount_uploader :avatar, AvatarUploader

  before_create :generate_unique_color

  has_many :likes,     dependent: :destroy
  has_many :pictures,  dependent: :destroy
  has_many :protips,   ->{ order(created_at: :desc) }, dependent: :destroy
  has_many :comments,  ->{ on_protips.order(created_at: :desc) }, dependent: :destroy
  has_many :badges,    ->{ order(created_at: :desc) }, dependent: :destroy
  has_many :streams,   ->{ order(created_at: :desc) }, dependent: :destroy

  RESERVED = %w{
    achievements
    admin
    administrator
    api
    broadcast
    contact_us
    emails
    faq
    impersonate
    live
    protips
    privacy_policy
    root
    stream
    streams
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

  validates_presence_of :username, :email

  def self.authenticate(username_or_email, password)
    param = username_or_email.to_s.downcase
    user  = where('username = ? OR email = ?', param, param).first
    user && user.authenticated?(password) ? user : nil
  end

  def email_optional?
    true #added this hack so clereance doesn't do email validation while bulk loading
  end

  def likes?(obj)
    likes.where(likable: obj).any?
  end

  def liked
    likes.collect(&:dom_id)
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
    self.skills = val.split(/,|\r\n|\n/).collect(&:strip)
  end

  def generate_stream_key
    self.stream_key = "cw_#{Digest::SHA1.hexdigest([Time.now.to_i, rand].join)[0..12]}"
  end

  def stream_name
    "#{username}?#{stream_key}"
  end

  def ownership
    return 0 if partner_coins.to_i <= 0
    amount = ((partner_coins.to_f / User.sum(:partner_coins).to_f).to_f * 100).round(2)
    if amount == 0.0
      amount = ((partner_coins.to_f / User.sum(:partner_coins).to_f).to_f * 100).round(4)
    end
    amount
  end

  def stream_sources
    [
      { file: "http://quickstream.io:1935/coderwall/ngrp:#{username}_all/jwplayer.smil"},
      { file: "http://quickstream.io:1935/coderwall/ngrp:#{username}_all/playlist.m3u8"},
    ]
  end

  def active_stream
    streams.not_archived.order(created_at: :desc).first
  end

  def unsubscribe_signature
    digest = OpenSSL::Digest.new('sha1')
    OpenSSL::HMAC.hexdigest(digest, ENV.fetch('UNSUBSCRIBE_SECRET', 'cw-unsub'), id.to_s)
  end

end
