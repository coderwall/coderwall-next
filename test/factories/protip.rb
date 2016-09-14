FactoryGirl.define do
  factory :protip do
    user
    title { Faker::Lorem.words }
    body  { Faker::Lorem.paragraphs }
    tags  { (1..5).map{|i| Faker::Lorem.word } }
  end
end
