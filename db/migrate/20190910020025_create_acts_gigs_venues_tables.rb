class CreateActsGigsVenuesTables < ActiveRecord::Migration[5.2]
  def change
    create_table :acts do |t|
      t.string :name
    end

    create_table :venues do |t|
      t.string :name
    end

    create_table :gigs do |t|
      t.references :acts
      t.references :venues
    end
  end
end
