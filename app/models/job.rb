class Job < ActiveRecord::Base

  scope :active, -> { where("expires_at > ?", Time.now) }

  def publish!(stripe_token)
    update!(
      stripe_token: stripe_token,
      expires_at: 1.month.from_now
    )
  end
end
