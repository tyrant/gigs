namespace :ticketmaster do
  
  desc "Grab the latest gigs from the Ticketmaster API, and update our local database with them"
  task update_from_api: :environment do

    old_gigs_count = Gig.count
    old_acts_count = Act.count
    old_venues_count = Venue.count

    incoming_gigs = TicketmasterService.get_all_gigs
    TicketmasterService.update_existing_gigs_with incoming_gigs

    puts "Gig-processing complete! Gigs: #{ old_gigs_count }->#{ Gig.count }; Acts: #{ old_acts_count }->#{ Act.count }; Venues: #{ old_venues_count }->#{ Venue.count }"
  end
end