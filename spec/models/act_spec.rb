require 'rails_helper'

describe Act do

  subject { build :act }

  it { is_expected.to have_many(:gigs).inverse_of(:act) }

end
