module Api
  module V1
    class VenueResource < JSONAPI::Resource

      attributes :name, :ticketmaster_id
      has_many :gigs, eager_load_on_include: false

      def fetchable_fields
        super - [:ticketmaster_id]
      end

      filter :acts,
        verify: -> (values, context) {
          values.map &:to_i
        },
        apply: -> (records, value, _options) {
          records.joins(gigs: :act).where('acts.id IN (:acts)', acts: value)
        }
    end
  end
end