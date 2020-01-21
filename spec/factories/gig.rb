FactoryBot.define do
  factory :gig do
    ticketmaster_id { Faker::Alphanumeric.alpha(number: 10) }
    at { Faker::Time.between(from: DateTime.now - 100.days, to: DateTime.now + 100.days) }
    act
    venue
  end
end