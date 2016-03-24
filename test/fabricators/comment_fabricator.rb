Fabricator(:comment) do
  body { Faker::Lorem.paragraph }
  protip  { Fabricate.build(:protip) }
  user     { Fabricate.build(:user) }
end
