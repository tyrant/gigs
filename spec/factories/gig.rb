FactoryBot.define do
  factory :gig do
    created_at { 
      Faker::Time.between(from: DateTime.now - 90.days, to: DateTime.now - 50.days) 
    }
    updated_at { 
      Faker::Time.between(from: DateTime.now - 50.days, to: DateTime.now - 10.days) 
    }
    ticketmaster_id { Faker::Alphanumeric.alpha(number: 10) }
    at { Faker::Time.between(from: DateTime.now - 100.days, to: DateTime.now + 100.days) }

    act
    venue
  end
end