require 'rails_helper'

describe "Search" do

  # We're creating each one individually so we can use their IDs in search.
  let!(:act1) { create :act }
  let!(:act2) { create :act }
  let!(:act3) { create :act }
  let!(:act4) { create :act }
  let!(:act5) { create :act }
  let!(:venue1) { create :venue }
  let!(:venue2) { create :venue }
  let!(:venue3) { create :venue }
  let!(:venue4) { create :venue }
  let!(:venue5) { create :venue }
  let!(:gig1) { create :gig, act: act1, venue: venue2 }
  let!(:gig2) { create :gig, act: act1, venue: venue2 }
  let!(:gig3) { create :gig, act: act1, venue: venue3 }
  let!(:gig4) { create :gig, act: act3, venue: venue3 }
  let!(:gig5) { create :gig, act: act3, venue: venue3 }
  let!(:gig6) { create :gig, act: act4, venue: venue3 }
  let!(:gig7) { create :gig, act: act4, venue: venue3 }
  let!(:gig8) { create :gig, act: act4, venue: venue3 }
  let!(:gig9) { create :gig, act: act4, venue: venue3 }
  let!(:gig10) { create :gig, act: act4, venue: venue4 }
  let!(:gig11) { create :gig, act: act5, venue: venue4 }

  before {
    get 'api/v1/search', params: params
  }

  describe "Filtering by Act" do

    context "Acts 1, 2, 5" do

      let(:params) {
        { acts: [act1.id, act2.id, act5.id] }
      }

      describe "returning venues 2, 4" do

        let(:venue_ids) {
          response.body['venues'].map(&:id)
        }

        it { expect(venue_ids).to include venue2.id }
        it { expect(venue_ids).to include venue4.id }
      end

      describe "attaching gigs 1, 2 to venue 2" do

        let(:gig_ids_for_venue_2) {
          response.body['venues'].filter do |response_venue|
            response_venue.id == venue2.id
          end['gigs'].map(&:id)
        }

        it { expect(gig_ids_for_venue_2).to include gig1.id }
        it { expect(gig_ids_for_venue_2).to include gig2.id }
      end

      describe "attaching gig 11 to venue 4" do

        let(:gig_ids_for_venue_4) {
          response.body['venues'].filter do |response_venue|
            response_venue.id == venue4.id
          end['gigs'].map(&:id)
        }

        it { expect(gig_ids_for_venue_4).to include gig11.id }

        it "does not attach gig 10 to venue 4 - only gigs performed by the acts queried" do
          expect(gig_ids_for_venue_4).not_to include gig10.id
        end
      end
    end

    context "Act 2 only" do

      let(:params) {
        { acts: [act2.id] }
      }

      it "returns zero venues" do
        expect(response.body['venues'].length).to eq 0
      end
    end

    context "Acts 2, 4" do

      let(:params) {
        { acts: [act2.id, act4.id] }
      }

      describe "returning venues 3, 4" do

        let(:venue_ids) {
          response.body['venues'].map(&:id)
        } 

        it { expect(venue_ids).to include venue3.id }
        it { expect(venue_ids).to include venue4.id }
      end

      describe "attaching gigs 6, 7, 8, 9 to venue 3" do

        let(:gig_ids_for_venue_3) {
          response.body['venues'].filter do |response_venue|
            response_venue.id == venue3.id
          end['gigs'].map(&:id)
        }

        it { expect(gig_ids_for_venue_3).to include gig6.id }
        it { expect(gig_ids_for_venue_3).to include gig7.id }
        it { expect(gig_ids_for_venue_3).to include gig8.id }
        it { expect(gig_ids_for_venue_3).to include gig9.id }
      end

      describe "attaching gig 10 to venue 4" do

        let(:gig_ids_for_venue_4) {
          response.body['venues'].filter do |response_venue|
            response_venue.id == venue3.id
          end['gigs'].map(&:id)
        }

        it { expect(gig_ids_for_venue_4).to include gig10.id }

        it "does not attach gig 11 - 11 attaches to act 5, which isn't in params" do
          expect(gig_ids_for_venue_4).to include gig11.id
        end
      end
    end
  end

  describe "Filtering by viewport bounds" do

  end

  describe "Filtering by start/end timestamps" do

  end
end