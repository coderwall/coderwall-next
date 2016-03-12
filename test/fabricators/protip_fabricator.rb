Fabricator(:protip) do
  title       { Faker::Lorem.sentence(rand(2..6))}
  body        { Faker::Lorem.paragraph(rand(30))}
  user_id     { Fabricate.build(:user) }
  tags {Faker::Lorem.words(4)}
end
