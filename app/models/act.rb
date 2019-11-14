class Act < ApplicationRecord

  has_many :gigs, inverse_of: :act
end