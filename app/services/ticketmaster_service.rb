module TicketmasterService

  EVENTS_URL = 'https://app.ticketmaster.com/discovery/v2/events.json'

  # Hit the Ticketmaster event discovery API, iterate over every page of
  # every single standup comedy event, grab the IDs, names and other relevant
  # attributes we may decide on later.
  # 
  def self.get_all_gigs
    # We shall populate this little bugger thusly:
    # gigs = [{ t_id, name, venue: { t_id, name }, act: { t_id, name }}, ...]
    gigs = []
    page = 0
    retries = 0

    while true do

      begin
        response = HTTParty.get(EVENTS_URL, query: {
          classificationName: 'Comedian',
          page: page,
          size: 20,
          apikey: Gigs::Application.credentials.ticketmaster_key
        })

      rescue Net::OpenTimeout => e
        if retries >= 10
          raise "Something is seriously wrong here, here's what HTTParty has to say:\n\n#{ e.message }"
        else
          retries += 1
          redo
        end
        
      end

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

  # Iterate over every gig from .get_all_gigs. For each not already existing, create it. 
  # The newly created ones will have acts and venues that may or may not already exist locally.
  # Query this. If they don't, create them too.
  # Param: an array of gig hashes.
  def self.update_existing_gigs(gigs)

    gigs.each do |incoming_gig|

      Gig.find_or_create_by ticketmaster_id: incoming_gig[:ticketmaster_id] do |gig|

        gig.act = Act.find_or_create_by ticketmaster_id: incoming_gig[:act][:ticketmaster_id] do |act|
          act.name = incoming_gig[:act][:name]
        end

        gig.venue = Venue.find_or_create_by ticketmaster_id: incoming_gig[:venue][:ticketmaster_id] do |venue|
          venue.name = incoming_gig[:venue][:name]
        end
      end
    end
  end

end