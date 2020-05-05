module Api
  module V1
    class GigResource < JSONAPI::Resource

      attributes :created_at, :updated_at, :at, :ticketmaster_id
      has_one :venue
      has_one :act

      def fetchable_fields
        super - [:ticketmaster_id]
      end
    end 
  end
end