class JobSubscription < ApplicationRecord
  CENTS_PER_MONTH = (ENV['JOB_SUBSCRIPTION_CENTS'].try(:to_i))

  validates :jobs_url, presence: true
  validates :company_name, presence: true
  validates :contact_email, presence: true

  def charge!(token)
    customer = Stripe::Customer.create(
      source: token,
      plan: (ENV['JOBS_PLAN'] || 'jobs_monthly'),
      email: contact_email,
    )

    update!(
      stripe_customer_id: customer.id,
      subscribed_at: Time.now,
    )
  end
end
