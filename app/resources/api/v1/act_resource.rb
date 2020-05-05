module Api
  module V1
    class ActResource < JSONAPI::Resource

      attributes :created_at, :updated_at, :name, :ticketmaster_id
      has_many :gigs

      def fetchable_fields
        super - [:ticketmaster_id]
      end
    end
  end
end