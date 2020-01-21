FactoryBot.define do
  factory :venue do
    name { Faker::Restaurant.name }
    ticketmaster_id { Faker::Alphanumeric.alpha(number: 10) }
  end
end