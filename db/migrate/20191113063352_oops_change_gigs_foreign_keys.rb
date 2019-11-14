class OopsChangeGigsForeignKeys < ActiveRecord::Migration[5.2]
  def change
    rename_column :gigs, :acts_id, :act_id
    rename_column :gigs, :venues_id, :venue_id
  end
end
