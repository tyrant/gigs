module Api
  module V1
    class ActResource < JSONAPI::Resource

      attributes :name, :ticketmaster_id
      has_many :gigs

      def fetchable_fields
        super - [:ticketmaster_id]
      end
    end
  end
end