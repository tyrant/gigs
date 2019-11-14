class AddTicketmasterIdsToTheUniverse < ActiveRecord::Migration[5.2]
  def change
    add_column :acts, :ticketmaster_id, :string
    add_column :gigs, :ticketmaster_id, :string
    add_column :venues, :ticketmaster_id, :string

    add_index :acts, :ticketmaster_id
    add_index :gigs, :ticketmaster_id
    add_index :venues, :ticketmaster_id
  end
end
