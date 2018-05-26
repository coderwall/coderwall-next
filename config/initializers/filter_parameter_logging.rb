# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += [
  :password,
  :password_confirmation,
  :username,
  :email,
  :name,
  :avatar,
  :title,
  :country,
  :city,
  :state_name,
  :company,
  :about,
  :team_id,
  :last_ip
]
