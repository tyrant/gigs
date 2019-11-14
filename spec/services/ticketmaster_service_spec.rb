require 'rails_helper'

describe "Ticketmaster service" do

  describe "The Ticketmaster API response itself" do

    let!(:schema) {
      {
        type: 'object',
        required: ['_embedded'],
        properties: {
          _embedded: {
            type: 'object',
            required: ['events'],
            properties: {
              events: {
                type: 'array',
                items: {
                  type: 'object',
                  required: ['name', 'type', 'id', '_embedded'],
                  properties: {
                    name: { type: 'string' },
                    type: { type: 'string' },
                    id: { type: 'string' },
                    _embedded: {
                      type: 'object',
                      required: ['venues', 'attractions'],
                      properties: {
                        venues: {
                          type: 'array',
                          items: {
                            type: 'object',
                            required: ['name', 'type', 'id'],
                            properties: {
                              name: { type: 'string' },
                              type: { type: 'string' },
                              id: { type: 'string' }
                            }
                          }
                        },
                        attractions: {
                          type: 'array',
                          items: {
                            type: 'object',
                            required: ['name', 'type', 'id'],
                            properties: {
                              name: { type: 'string' },
                              type: { type: 'string' },
                              id: { type: 'string' }
      }}}}}}}}}}}}
    }

    it "returns the schema we're expecting" do
      query = { 
        classificationName: 'Comedian', 
        size: 1, 
        apikey: Gigs::Application.credentials.ticketmaster_key 
      }
      path = 'https://app.ticketmaster.com/discovery/v2/events.json'

      VCR.use_cassette 'services/ticketmaster_service_api', re_record_interval: 1.day do
        response = HTTParty.get(path, query: query).parsed_response
        errors = JSON::Validator.fully_validate(schema, response)

        expect(errors).to eq []
      end
    end
  end

  describe '.get_all_gigs' do

    let!(:schema) {
      {
        type: 'array',
        items: {
          type: 'object',
          required: ['name', 'ticketmaster_id', 'venue', 'act'],
          properties: {
            name: { type: 'string' },
            ticketmaster_id: { type: 'string' },
            venue: {
              type: 'object',
              required: ['name', 'ticketmaster_id'],
              properties: {
                #name: { type: 'string' }, Sometimes Ticketmaster returns null venue names!
                ticketmaster_id: { type: 'string' },
              }
            },
            act: {
              type: 'object',
              required: ['name', 'ticketmaster_id'],
              properties: {
                name: { type: 'string' },
                ticketmaster_id: { type: 'string' },
      }}}}}
    }

    it "returns the schema we're expecting for every single gigs item" do
      VCR.use_cassette 'services/ticketmaster_service_get_all_gigs', re_record_interval: 1.day do
        gigs = TicketmasterService.get_all_gigs
        errors = JSON::Validator.fully_validate(schema, gigs)
        expect(errors).to eq []
      end
    end
  end

  # Assumptions: we won't ever get an existing gig with changed/updated attributes or relationships.
  # Though we were wrong about Ticketmaster venues never having null names, weren't we. Maybe we're
  # wrong about this too. But let's cross that bridge should we ever come to it.
  describe '.update_existing_gigs' do

    let!(:act1) { create :act, ticketmaster_id: 'aid1' }
    let!(:venue1) { create :venue, ticketmaster_id: 'vid1' }
    let!(:venue2) { create :venue, ticketmaster_id: 'vid2 '}
    let!(:gig1) { create :gig, ticketmaster_id: 'gid1', act: act1, venue: venue1 }
    let!(:gig2) { create :gig, ticketmaster_id: 'gid2', act: act1, venue: venue2 }

    let!(:incoming_gigs) {
      [{
        name: 'gig1',
        ticketmaster_id: 'gid1', # Existing gig
        venue: {
          name: 'venue1',
          ticketmaster_id: 'vid1', # Existing venue
        },
        act: {
          name: 'act1',
          ticketmaster_id: 'aid1', # Existing act
        },
      }, {
        name: 'gig2',
        ticketmaster_id: 'gid2', # Existing gig
        venue: {
          name: 'venue2',
          ticketmaster_id: 'vid2', # Existing venue
        },
        act: {
          name: 'act1',
          ticketmaster_id: 'aid1', # Existing act
        },
      }, {
        name: 'gig3',
        ticketmaster_id: 'gid6', # New gig!
        venue: {
          name: 'venue3',
          ticketmaster_id: 'vid1' # Existing venue
        },
        act: {
          name: 'act3',
          ticketmaster_id: 'aid1', # Existing act
        },
      }, {
        name: 'gig4',
        ticketmaster_id: 'gid7', # New gig!
        venue: {
          name: 'venue7',
          ticketmaster_id: 'vid7' # New venue!
        },
        act: {
          name: 'act32',
          ticketmaster_id: 'aid32' # New act!
        },
      }]
    }

    it "creates two new gigs" do
      expect { TicketmasterService.update_existing_gigs(incoming_gigs) }
        .to change { Gig.count }
        .by 2
    end

    it "creates one new venue" do
      expect { TicketmasterService.update_existing_gigs(incoming_gigs) }
        .to change { Venue.count }
        .by 1
    end

    it "creates one new act" do
      expect { TicketmasterService.update_existing_gigs(incoming_gigs) }
        .to change { Act.count }
        .by 1
    end
  end
end