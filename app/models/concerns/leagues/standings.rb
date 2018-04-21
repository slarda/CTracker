require 'active_support/concern'

module Leagues
  module Standings
    extend ActiveSupport::Concern

    included do

      def obtain_teams_clubs_games(league, season)
        teams = league.teams.includes(:club, :league).select('id,name,club_id,display_state,league_id')
        clubs = league.teams.map(&:club).map(&:attributes).collect do |attrs|
          attrs.select { |k, _v| k == 'id' or k == 'name' }
        end
        games = Team.all_games_for_teams(teams, season)
        [teams, clubs, games]
      end

      def summarise_league_standings(teams, clubs, games)
        results = []
        teams.each do |team|
          results.push standings_result_hash(team,
                                             clubs.select { |club| club['id'] == team['club_id'] }.first,
                                             games.select { |game| game.home_team_id == team['id'] or
                                                                   game.away_team_id == team['id'] })
        end
        sorted = results.sort { |x, y| sort_by_points_then_goals(x, y) }
        sorted.each_with_index do |standing, i|
          standing['id'] = i + 1
        end
        sorted
      end

      private

      def sort_by_points_then_goals(x, y)
        return y[:gf] <=> x[:gf] if y[:points] == x[:points] and y[:gd] == x[:gd]
        return y[:gd] <=> x[:gd] if y[:points] == x[:points]
        y[:points] <=> x[:points]
      end

      def standings_result_hash(team, club, games)
        result = { team_id: team.id, club_id: club['id'], name: team['name'] }
        calculate_win_loss_draw(result, team.id, games)
        calculate_goals_scored_conceded(result, team.id, games)
        result
      end

      def calculate_win_loss_draw(result, team_id, games)
        result[:win] = 0
        result[:draw] = 0
        result[:loss] = 0
        result[:played] = 0
        result[:points] = 0

        games.each do |game|
          next unless game.home_team_score and game.away_team_score
          result[:played] += 1

          if game.home_team_id == team_id
            increment_wld(result, game.home_team_score, game.away_team_score)
          else
            increment_wld(result, game.away_team_score, game.home_team_score)
          end
        end
      end

      def increment_wld(result, score1, score2)
        if score1 > score2
          increment_win(result)
        elsif score1 == score2
          increment_draw(result)
        else
          result[:loss] += 1
        end
      end

      def increment_win(result)
        result[:win] += 1
        result[:points] += 3
      end

      def increment_draw(result)
        result[:draw] += 1
        result[:points] += 1
      end

      def calculate_goals_scored_conceded(result, team_id, games)
        result[:gf] = 0
        result[:ga] = 0

        games.each do |game|
          next unless game.home_team_score and game.away_team_score
          if game.home_team_id == team_id
            result[:gf] += game.home_team_score
            result[:ga] += game.away_team_score
          else
            result[:gf] += game.away_team_score
            result[:ga] += game.home_team_score
          end
        end

        result[:gd] = result[:gf] - result[:ga]
      end
    end
  end
end
