require 'active_support/concern'

module PlayerResults
  module Callbacks
    extend ActiveSupport::Concern

    included do

      def increment_game
        return unless game
        specialized ||= {}
        dup_specialized(self)
        game.specialized ||= {}

        if sport.eql?('soccer')
          #game.goals += goals # home_team_score / away_team_score
          #game.own_goals += own_goals
          if home_game?
            game.specialized[:home_red_cards]     ||= 0
            game.specialized[:home_yellow_cards]  ||= 0
            game.specialized[:home_red_cards]     += specialized[:red_cards] || 0
            game.specialized[:home_yellow_cards]  += specialized[:yellow_cards] || 0
          else
            game.specialized[:away_red_cards]     ||= 0
            game.specialized[:away_yellow_cards]  ||= 0
            game.specialized[:away_red_cards]     += specialized[:red_cards] || 0
            game.specialized[:away_yellow_cards]  += specialized[:yellow_cards] || 0
          end
        end
        game.save!
      end

      def decrement_game(game_to_decr = nil)
        return unless game
        game ||= game_to_decr
        return unless game
        game.specialized ||= {}

        if sport.eql?('soccer')
          #game.goals -= goals
          #game.own_goals -= own_goals
          if home_game?
            game.specialized[:home_red_cards]     ||= 0
            game.specialized[:home_yellow_cards]  ||= 0
            game.specialized[:home_red_cards]     -= prev_specialized[:red_cards] || 0
            game.specialized[:home_yellow_cards]  -= prev_specialized[:yellow_cards] || 0
          else
            game.specialized[:away_red_cards]     ||= 0
            game.specialized[:away_yellow_cards]  ||= 0
            game.specialized[:away_red_cards]     -= prev_specialized[:red_cards] || 0
            game.specialized[:away_yellow_cards]  -= prev_specialized[:yellow_cards] || 0
          end
          return true
        end
        false
      end

      def unlink_game
        game.save! if decrement_game(game)
      end

      def dup_specialized(pr)
        pr.prev_specialized = pr.specialized.try(:deep_dup) || {}
      end

    end
  end
end