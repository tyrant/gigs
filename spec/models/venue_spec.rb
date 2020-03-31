require 'rails_helper'

describe Venue do

  subject { build :venue }

  it { is_expected.to have_many(:gigs).inverse_of(:venue) }

end