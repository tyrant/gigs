module TicketmasterService

  EVENTS_URL = 'https://app.ticketmaster.com/discovery/v2/events.json'

  # Hit the Ticketmaster event discovery API, iterate over every page of
  # every single standup comedy event, grab the IDs, names and other relevant
  # attributes we may decide on later.
  # 
  def self.get_all_gigs
    # We're going to fill this little bugger up thusly:
    # gigs = [{ t_id, name, venue: { t_id, name }, act: { t_id, name }}, ...]
    gigs = []

    page = 0
    while true do
      response = HTTParty.get(EVENTS_URL, query: {
        classificationName: 'Comedian',
        page: page,
        size: 20,
        apikey: Gigs::Application.credentials.ticketmaster_key
      })

      response.code == 400 ? break : page += 1

      response.parsed_response['_embedded']['events'].each do |event|
        gigs << {
          ticketmaster_id: event['id'],
          name: event['name'],
          venue: {
            ticketmaster_id: event['_embedded']['venues'][0]['id'],
            name: event['_embedded']['venues'][0]['name'],
          },
          act: {
            ticketmaster_id: event['_embedded']['attractions'][0]['id'],
            name: event['_embedded']['attractions'][0]['name'],
          }
        }
      end
    end

    gigs
  end

end