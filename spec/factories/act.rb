FactoryBot.define do
  factory :act do
    created_at { 
      Faker::Time.between(from: DateTime.now - 90.days, to: DateTime.now - 50.days) 
    }
    updated_at { 
      Faker::Time.between(from: DateTime.now - 50.days, to: DateTime.now - 10.days) 
    }
    name { Faker::Artist.name }
    ticketmaster_id { Faker::Alphanumeric.alpha(number: 10) }
  end
end