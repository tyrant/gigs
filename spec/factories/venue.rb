FactoryBot.define do
  factory :venue do
    name { Faker::Restaurant.name }
  end
end