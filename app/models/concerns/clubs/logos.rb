require 'active_support/concern'

module Clubs
  module Logos
    extend ActiveSupport::Concern

    module ClassMethods

      def load_logos
        Dir.foreach(Rails.root.join('data', 'logos')) do |logo|
          next if logo == '.' or logo == '..'

          puts "... #{logo}"
          matched = /^(.*)(FC|SC)/.match(logo)
          next unless matched
          club_name = matched[1].split(/(?=[A-Z])/).join(' ')
          club = Club.where('name like ?', club_name + '%').first
          if club and club.logo.url.nil?
            club.logo = File.new(Rails.root.join('data', 'logos', logo))
            club.save!
          end
        end

        # Special handling for the special ones... there is always a few
        bulleen = Club.where('name like ?', 'FC Bulleen Lions%').first
        if bulleen
          bulleen.logo = File.new(Rails.root.join('data', 'logos', 'FCBulleenLionsFC.gif'))
          bulleen.save!
        end

        ntc_blue = Club.where('name like ?', 'NTC Blue%').first
        if ntc_blue
          ntc_blue.logo = File.new(Rails.root.join('data', 'logos', 'NTCBlueFC.gif'))
          ntc_blue.save!
        end

        ntc_red = Club.where('name like ?', 'NTC Red%').first
        if ntc_red
          ntc_red.logo = File.new(Rails.root.join('data', 'logos', 'NTCRedFC.gif'))
          ntc_red.save!
        end

        # ntc = Club.where('name like ?', 'NTC FC').first
        # ntc.logo = File.new(Rails.root.join('data', 'logos', 'NTCFC.gif'))
        # ntc.save!

      end
    end
  end
end