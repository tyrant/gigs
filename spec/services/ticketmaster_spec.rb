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

  describe '#get_all_gigs' do

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

    it "returns the schema we're expecting" do
      VCR.use_cassette 'services/ticketmaster_service_get_all_gigs', re_record_interval: 1.day do
        gigs = TicketmasterService.get_all_gigs
        errors = JSON::Validator.fully_validate(schema, gigs)
        expect(errors).to eq []
      end
    end

  end
end