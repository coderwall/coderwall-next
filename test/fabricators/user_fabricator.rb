Fabricator(:user) do
  last_ip               { Faker::Internet.ip_v4_address }
  username              { Faker::Internet.user_name }
  email                 { Faker::Internet.email }
  password              'FBIWantABackdoorHereToo'
end
