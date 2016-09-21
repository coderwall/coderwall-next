FactoryGirl.define do
  factory :user do
    sequence(:username) {|i| "user_#{i}" }
    email    { Faker::Internet.email }
    password { Faker::Internet.password }
  end
end
