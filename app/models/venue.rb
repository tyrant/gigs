class Venue < ApplicationRecord

  has_many :gigs, inverse_of: :venue
end