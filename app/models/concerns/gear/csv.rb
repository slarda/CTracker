require 'active_support/concern'

module Gear
  module Csv
    extend ActiveSupport::Concern

    module ClassMethods

      # def si(x)
      #   # All data should be set to 0 (if not available)
      #   x.try(:strip).try(:to_i) || 0
      # end
      #
      # def si_blank(x)
      #   # Either an integer, or nil
      #   x.try(:strip).try(:to_i)
      # end

      def st(x)
        x.try(:strip)
      end

      def load_gear(filename)

        count = 0
        CSV.open(filename, headers: true).each do |row|

          # Get the standard equipment type
          equipment_type = case st(row['Gear'])
                             when 'Boots' then :boots
                             when 'Goalkeeper Gloves' then :gloves
                             when 'Shin Pads' then :shinpads
                             else :unknown
                           end

          # Locate brand
          brand = Brand.where(name: st(row['Brand'])).first_or_create!

          # Create equipment
          equipment = Equipment.where(equipment_type: equipment_type, brand: brand, model: st(row['Model'])).first_or_initialize
          equipment.specialized ||= {}
          equipment.specialized[:surface] = st(row['Surface'])
          equipment.specialized[:colour] = st(row['Colour'])
          equipment.specialized[:size] = st(row['Size'])
          equipment.specialized[:sex] = st(row['Sex'])
          equipment.specialized[:age] = st(row['Age'])
          equipment.save!

          count += 1
        end

        count
      end
    end
  end
end