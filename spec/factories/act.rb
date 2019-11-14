FactoryBot.define do
  factory :act do
    name { Faker::Artist.name }
  end
end