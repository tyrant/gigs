require 'rails_helper'

shared_examples "general jsonapi behaviour for" do |klass|

  it 'returns the jsonapi Content-Type' do
    expect(response.headers['Content-Type']).to eq 'application/vnd.api+json'
  end

  it 'returns an array of jsonapi objects' do
    expect(response_json['data']).to match_jsonapi_array_schema
  end

  it 'returns all type=="klass"' do
    expect(response_json['data']).to match_jsonapi_array_types_for klass
  end
end

describe "Search" do

  # Create a big bunch of pseudorandomly linked models.
  # We only require five identical Acts, so we can just use create_list
  # to create an array of them directly.
  let!(:acts) { create_list :act, 5 }

  # Here, we need another five Venues, but with unique updated_at values,
  # so we'll neeed to iterate through an integer array and use its values
  # to populate each Venue's updated_at attribute.
  let!(:venues) {
    [9, 3, 7, 2, 8].map do |days_ago|
      create :venue, updated_at: Time.now - days_ago.days
    end 
  }
 
  # Same again, but with gigs: create eleven Gigs, each with unique
  # act_id, venue_id and at attribute values. They're all integers,
  # so we can just simply use an array of arrays: each array-entry is
  # [act_id, venue_id], and that entry's index value in the parent 
  # array can build its at attribute value. 
  let!(:gigs) {
    [[0,0], [0,0], [0,0], [2,1], [2,1], [3,1], [3,1], [3,1], [3,1], [3,2], [4,2]].each_with_index.map do |ids, i|
      create :gig, act: acts[ids[0]], venue: venues[ids[1]], at: Time.now + (i+3).days 
    end
  }

  before {
    get api_v1_venues_path, params: params
  }

  describe 'Querying API with zero params of any kind' do
    include_examples 'general jsonapi behaviour for', Venue
    let(:params) { {} }
  end

  describe "Filtering by Act" do
    include_examples 'general jsonapi behaviour for', Venue

    context "Not supplying any act IDs" do

      let(:params) { { filter: { acts: '' } } }

      it "returns every single venue, ordered by updated_at desc" do
        # Manually order our five venues descending by updated_at
        resources = [venue4, venue2, venue3, venue5, venue1].map do |venue|
          Api::V1::VenueResource.new(venue, nil)
        end

        # jsonapi-resources 0.9 has a bug concerning link construction - all its
        # other serialized data has string keys, but its data keys are symbols.
        # We *could* jump into its callbacks and manually stringify its keys ...
        # ... Or just call #deep_stringify_keys! here.
        serialized_resources = JSONAPI::ResourceSerializer
          .new(Api::V1::VenueResource)
          .serialize_to_hash(resources)
          .deep_stringify_keys!

        expect(response_json['data']).to eq serialized_resources['data']
      end
    end

    context "Acts 1, 2, 5" do

      let(:acts) { [act1, act2, act5] }

      let(:params) { { filter: { acts: acts.map(&:id).join(',') } } }

      describe "returning only venues 4, 2, 3: updated_at desc" do

        let(:venueresources_4_2_3) {
          [venue4, venue2, venue3].map { |v| Api::V1::VenueResource.new(v, nil) }
        } 

        let(:svrs_4_2_3_data) {
          JSONAPI::ResourceSerializer.new(Api::V1::VenueResource)
            .serialize_to_hash(venueresources_4_2_3)
            .deep_stringify_keys!['data']
        }

        let(:svrs_4_2_3_data_w_gigs_for_acts_1_2_5) {
          svrs_4_2_3_data.each do |svr| 
            svr['relationships']['gigs']['data'].select! do |sgr|
              acts.include? Gig.find(sgr['id']).act
            end
          end
        }

        it "returns only the venues and gigs attended by Acts 1, 2 and 5" do
          expect(svrs_4_2_3_data_w_gigs_for_acts_1_2_5)
            .to eq response_json['data']
        end



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