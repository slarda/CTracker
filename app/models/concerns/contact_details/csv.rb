require 'active_support/concern'

module ContactDetails
  module Csv
    extend ActiveSupport::Concern

    module ClassMethods

      def load_venues(filename)
        CSV.open(filename, headers: true).each do |row|
          venue = ContactDetail.where(address1: row['Address1'].strip).first_or_initialize
          venue.address2 = row['Address2'].try(:strip)
          venue.address3 = row['Address3'].try(:strip)
          venue.suburb = row['Suburb'].try(:strip)
          venue.state = row['State'].try(:strip)
          venue.zipcode = row['Postcode'].try(:strip)
          venue.longitude = row['Longitude'].try(:strip).try(:to_f)
          venue.latitude = row['Latitude'].try(:strip).try(:to_f)
          venue.google_id = row['GooglePlacesId'].try(:strip)
          venue.save!
        end
      end
    end
  end
end

