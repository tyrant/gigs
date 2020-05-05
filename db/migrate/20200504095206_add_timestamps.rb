class AddTimestamps < ActiveRecord::Migration[5.2]

  def up
    %w(gigs acts venues).each do |model|
      %w(created_at updated_at).each do |column|
        add_column model, column, :datetime, null: false, default: Time.now
      end
    end
  end

  def down
    %w(gigs acts venues).each do |model|
      %w(created_at updated_at).each do |column|
        remove_column model, column
      end
    end
  end
end
