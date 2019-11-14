class Gig < ApplicationRecord

  belongs_to :venue, inverse_of: :gigs
  belongs_to :act, inverse_of: :gigs
end