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
    get api_v1_venues_path, params: params
  }

  describe "Querying API with zero params of any kind" do
    let(:params) { {} }

    it "returns the jsonapi Content-Type" do
      expect(response.headers['Content-Type']).to eq 'application/vnd.api+json'
    end
  end

  describe "Filtering by Act" do

    context "Not supplying any act IDs" do

      let(:params) {}

      describe "returning every single venue" do

        subject { response_json }

        it { is_expected.to include(
          *[venue1, venue2, venue3, venue4, venue5].map { |venue| 
            venue.as_json(include: :gigs) 
          }
        )}
      end
    end

    context "Acts 1, 2, 5" do

      let(:params) {
        { acts: [act1.id, act2.id, act5.id] }
      }

      describe "returning only venues 2, 3, 4" do
        
        subject { response_json }

        it { is_expected.to include(
          *[venue2, venue3, venue4].map { |venue| 
            venue.as_json(include: :gigs) 
          }
        )}

        it { is_expected.not_to include(
          *[venue1, venue5].map { |venue| 
            venue.as_json(include: :gigs) 
          }
        )}

        describe "ordering"
      end

      describe "returning only gigs 1, 2 with venue 2" do

        subject {
          response_json.find do |response_venue|
            response_venue['id'] == venue2.id
          end['gigs']
        }

        it { is_expected.to include(
          *[gig1, gig2].map(&:as_json)
        )}

        it { is_expected.not_to include(
          *[gig3, gig4, gig5, gig6, gig7, gig8, gig9, gig10, gig11].map(&:as_json)
        )}
      end

      describe "returning only gigs 10, 11 vith venue 4" do

        subject {
          response_json.find do |response_venue|
            response_venue['id'] == venue4.id
          end['gigs']
        }

        it { is_expected.to include(
          *[gig10, gig11].map(&:as_json)
        )}

        it { is_expected.not_to include(
          *[gig1, gig2, gig3, gig4, gig5, gig6, gig7, gig8, gig9].map(&:as_json)
        )}

      end
    end

    context "Act 2 only" do

      let(:params) {
        { acts: [act2.id] }
      }

      it "returns zero venues" do
        expect(response_json.length).to eq 0
      end
    end

    context "Acts 2, 4" do

      let(:params) {
        { acts: [act2.id, act4.id] }
      }

      describe "returning only venues 3, 4" do

        subject { response_json }

        it { is_expected.to include(
          *[venue3, venue4].map { |venue| 
            venue.as_json(include: :gigs) 
          }
        )}

        it { is_expected.not_to include(
          *[venue1, venue2, venue5].map {|venue| 
            venue.as_json(include: :gigs) 
          }
        )}
      end

      describe "returning only gigs 3, 4, 5, 6, 7, 8, 9 with venue 3" do

        subject {
          response_json.find do |response_venue|
            response_venue['id'] == venue3.id
          end['gigs']
        }

        it { is_expected.to include(
          *[gig3, gig4, gig5, gig6, gig7, gig8, gig9].map(&:as_json)
        )}

        it { is_expected.not_to include(
          *[gig1, gig2, gig10, gig11].map(&:as_json)
        )}
      end

      describe "returing only gigs 10, 11 with venue 4" do

        subject {
          response_json.find do |response_venue|
            response_venue['id'] == venue4.id
          end['gigs']
        }

        it { 
          is_expected.to include(
            *[gig10, gig11].map(&:as_json)
          )
        }

        it { 
          is_expected.not_to include(
            *[gig1, gig2, gig3, gig4, gig5, gig6, gig7, gig8, gig9].map(&:as_json)
          )
        }
      end
    end

    context "Act ID that isn't in the database" do

      let(:params) {
        { acts: [act1.id, 99999999] }
      }

      describe "just ignores it, returns venues for existing, valid acts" do

        subject { response_json }

        it { 
          is_expected.to include(
            *[venue2, venue3].map {|v| 
              v.as_json(include: :gigs) 
            }
          )
        }

        it { 
          is_expected.not_to include(
            *[venue1, venue4, venue5].map {|v| 
              v.as_json(include: :gigs) 
            }
          )
        }
      end
    end

    context "Malformed act ID" do
      
      let(:params) {
        { acts: ['blargh string bad'] }
      }

      it "has status=error" do
        expect(response_json['status']).to eq 'error'
      end

      it "contains an error message" do
        expect(response_json['error'][0]).to include "The property '#/acts/0' of type string did not match the following type: integer"
      end
    end
  end

  describe "Filtering by viewport bounds" do

  end

  describe "Filtering by start/end timestamps" do

  end
end