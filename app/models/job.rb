class Job < ActiveRecord::Base
  CENTS_PER_MONTH = 29900
  COST            = CENTS_PER_MONTH/100
  FULLTIME        = 'Full Time'
  PARTTIME        = 'Part Time'
  CONTRACT        = 'Contract'
  ROLES           = [FULLTIME, PARTTIME, CONTRACT]

  scope :active, -> { where("expires_at > ?", Time.now) }

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
