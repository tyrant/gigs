namespace :ticketmaster do
  desc "Grab the latest gigs from the Ticketmaster API, and update our local database with them"
  task update_from_api: :environment do
    gigs = TicketmasterService.get_all_gigs
    TicketmasterService.update_existing_gigs(gigs)
  end
end