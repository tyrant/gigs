require 'rails_helper'

describe Gig do

  subject { build :gig }

  it { is_expected.to belong_to(:venue).inverse_of(:gig) }
  it { is_expected.to belong_to(:act).inverse_of(:gig) }
  it { is_expected.to validate_presence_of(:venue) }
  it { is_expected.to validate_presence_of(:act) }

end