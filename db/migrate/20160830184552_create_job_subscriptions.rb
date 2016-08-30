class CreateJobSubscriptions < ActiveRecord::Migration
  def change
    create_table :job_subscriptions, id: :uuid do |t|
      t.timestamps                  null: false
      t.string :jobs_url,           null: false
      t.string :company_name,       null: false
      t.string :contact_email,      null: false
      t.string :stripe_customer_id
      t.string :subscribed_at
    end
  end
end
