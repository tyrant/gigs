module Api
  module V1
    class VenueResource < JSONAPI::Resource

      attributes :created_at, :updated_at, :name, :ticketmaster_id
      has_many :gigs, always_include_linkage_data: true

      def fetchable_fields
        super - [:ticketmaster_id]
      end

      filter :acts,
        verify: -> (values, context) {
          values.map &:to_i
        },
        apply: -> (records, value, _options) {
          q = records.includes(gigs: :act)
          q = q.where('acts.id IN (:acts)', acts: value) if value.length > 0
          q
        }

      def self.default_sort
        [{ field: 'updated_at', direction: 'desc' }]
      end
    end
  end
end