class AddPartnerInfo < ActiveRecord::Migration
  def change
    add_column :users, :partner_last_contribution_at, :datetime
    add_column :users, :partner_asm_username, :string
    add_column :users, :partner_slack_username, :string
    add_column :users, :partner_email, :string
    add_column :users, :partner_coins, :integer    
  end
end
