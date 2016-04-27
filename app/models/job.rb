class Job < ActiveRecord::Base
  CENTS_PER_MONTH = 29900
  COST            = CENTS_PER_MONTH/100
  FULLTIME        = 'Full Time'
  PARTTIME        = 'Part Time'
  CONTRACT        = 'Contract'
  ROLES           = [FULLTIME, PARTTIME, CONTRACT]

  validates :author_email, presence: true
  validates :author_name, presence: true
  validates :company_logo, presence: true
  validates :company_url, presence: true
  validates :company, presence: true
  validates :company, presence: true
  validates :location, presence: true
  validates :role_type, presence: true
  validates :source, presence: true
  validates :title, presence: true

  scope :active,   -> { where("expires_at > ?", Time.now) }
  scope :latest,   ->(count=1) { order(created_at: :desc).limit(count) }
  scope :featured, ->(count=1) { active.order("RANDOM()").limit(count) }

  def charge!(token)
    charge = Stripe::Charge.create(
      amount: CENTS_PER_MONTH, # amount in cents, again
      currency: "usd",
      source: token,
      description: "coderwall.com job posting"
    )

    update!(
      stripe_charge: charge.id,
      expires_at: 1.month.from_now
    )
  end
end
