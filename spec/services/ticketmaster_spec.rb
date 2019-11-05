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
      response = HTTParty.get(path, query: query).parsed_response
      errors = JSON::Validator.fully_validate(schema, response)

      expect(errors).to eq []
    end
  end
end

#curl --include 'https://app.ticketmaster.com/discovery/v2/events.json?classificationName=Comedian&apikey=kW7Cb9udjrC7APKvqYA9mtaSe2KWRMGf'