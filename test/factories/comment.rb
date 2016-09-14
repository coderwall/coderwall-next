FactoryGirl.define do
  factory :comment do
    association :article, factory: :protip
    user
    body { Faker::Lorem.words }
  end
end
