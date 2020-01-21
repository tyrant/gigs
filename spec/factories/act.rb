FactoryBot.define do
  factory :act do
    name { Faker::Artist.name }
    ticketmaster_id { Faker::Alphanumeric.alpha(number: 10) }
  end
end