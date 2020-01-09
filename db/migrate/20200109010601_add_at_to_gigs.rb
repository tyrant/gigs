class AddAtToGigs < ActiveRecord::Migration[5.2]
  def change
    add_column :gigs, :at, :datetime
  end
end
