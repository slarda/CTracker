module Users
  module Statistics
    extend ActiveSupport::Concern

    included do

    private

      # Note: side-effect is @user
      def get_season_stats(player_id, sport = 'soccer', all_games = false)
        @user = User.includes([:team, { :teams_past => [:home_games, :away_games] }, :sport_profiles]).find(player_id)

        # Query 1: Get team data
        team_games = obtain_team_games(@user, sport, all_games)
        is_a_coach = @user.sport_profiles.where(sport: sport).first.try(:position) == 'Coach'

        # Query 2: Get all the player's results and associated game data
        player_results = if is_a_coach
                           team_results(@user.team.id, team_games.pluck(:id))
                         else
                           team_player_results(@user.id, sport)
                         end

        map = {}
        process_player_results(player_results, map, is_a_coach, @user.id)
        process_team_games(@user.team, team_games, map, is_a_coach)
        all_games = obtain_all_game_stats(map)
        role_varieties = obtain_role_varieties(@user, team_games, map)

        {by_season: map.values.sort { |x,y| y[:season] <=> x[:season] }, all_time: all_games, role_stats: role_varieties}
      end

      def get_player_stats(player_id, sport = 'soccer', all_games = false)
        @user = User.includes([:team, { :teams_past => [:home_games, :away_games] }, :sport_profiles]).find(player_id)
        team_games = obtain_team_games(@user, sport, all_games)
        player_results = team_player_results(@user.id, sport)
        map = {}
        process_player_team_results(player_results, map)
        map
      end

      def obtain_team_games(user, sport, all_games)
        return [] unless user.team
        all_teams = user.teams_past.pluck(:id) + [user.team.id]
        if all_games
          Game.where('(home_team_id IN (?) OR away_team_id IN (?)) AND sport = ?', all_teams, all_teams, sport)
        else
          # TODO: think about whether we need to separate out teams past vs current team. Otherwise, we might look at
          # forward games for past teams that the player is no longer participating in, and this will affect their
          # statistic calculations
          Game.where('(home_team_id IN (?) OR away_team_id IN (?)) AND sport = ? AND start_date < ?',
                     all_teams, all_teams, sport, DateTime.current)
        end
      end

      def team_player_results(player_id, sport)
        PlayerResult.where(player_id: player_id).includes(:game => [:venue, :home_team, :away_team, :assoc]).
            where(sport: sport)
      end

      def team_results(team_id, team_game_ids)
        PlayerResult.where(team_id: team_id, game_id: team_game_ids).
            includes(:game => [:venue, :home_team, :away_team, :assoc])
      end

      def process_player_results(player_results, map, is_a_coach = false, coach_id = nil)
        player_results.each do |result|
          season = result.try(:game).try(:season)
          next unless season
          map_season = map[season] || {}
          initialize_map_season(map_season, season)

          # Skip to the next game if we didn't play
          (map[season] = map_season; next) unless result.played_game or is_a_coach # TODO: Still your own team! Ask Con later to confirm


          map_season[:goals] += (result.goals || 0) unless is_a_coach
          map_season[:games] += 1 unless is_a_coach and not result.player_id == coach_id

          # Game specific stuff
          increment_win_loss_draw(map_season, result) unless is_a_coach
          increment_sport_varieties(map_season, result, is_a_coach, coach_id)

          map[season] = map_season
        end
      end

      def process_player_team_results(player_results, map)
        player_results.each do |result|
          season = result.try(:game).try(:season)
          team = result.try(:team)
          key = season + team.name

          map_season = map[key] || {}

          map_season[:season] = season
          map_season[:team] = team.name
          map_season[:club_logo] = team.club.logo.url
          map_season[:club_id] = team.club.id
          [:goals, :team_goals, :team_conceded, :games, :team_games, :win, :lose, :draw, :red_cards, :yellow_cards,
         :assists, :penalty_saves, :clean_sheets].each do |kind|
            map_season[kind] ||= 0
          end

          next unless result.played_game

          map_season[:goals] += (result.goals || 0)
          map_season[:games] += 1
          increment_win_loss_draw(map_season, result)
          increment_sport_varieties(map_season, result)
          map[key] = map_season
        end
      end

      def process_team_games(team, team_games, map, is_a_coach = false)
        team_games.each do |game|
          season = game.season
          map_season = map[season] || {}
          map_season[:season] = season
          map_season[:team_games] ||= 0
          map_season[:team_games] += 1 if game.start_date <= DateTime.current

          # Ensure all values are zeroed even if no player results
          [:goals, :team_goals, :team_conceded, :games, :win, :lose, :draw, :red_cards, :yellow_cards, :assists,
                    :penalty_saves, :clean_sheets].each do |kind|
            map_season[kind] ||= 0
          end

          # Increment based on goals scored or conceded
          if game.home_team_score and game.away_team_score
            away_game = game.home_team_id != team.id
            map_season[:team_goals] +=     away_game ? game.away_team_score : game.home_team_score
            map_season[:team_conceded] +=  away_game ? game.home_team_score : game.away_team_score

            if is_a_coach
              # Handle win-loss-record for coaches (1 per game, not 1 per player result)
              increment_win_loss_draw_with_game(map_season, away_game, game)

              map_season[:goals] = map_season[:team_goals]
            end

          end

          map[season] = map_season
        end
      end

      def initialize_map_season(map_season, season)
        map_season[:season] = season

        [:goals, :team_goals, :team_conceded, :games, :team_games, :win, :lose, :draw, :red_cards, :yellow_cards,
         :assists, :penalty_saves, :clean_sheets].each do |kind|
          map_season[kind] ||= 0
        end
      end

      def increment_win_loss_draw(map_season, result)
        away_game = result.home_or_away.eql?('away_game')
        increment_win_loss_draw_with_game(map_season, away_game, result.game)
      end

      def increment_win_loss_draw_with_game(map_season, away_game, game)
        return unless game.home_team_score and game.away_team_score

        if (not away_game and (game.home_team_score > game.away_team_score)) or
            (away_game and (game.home_team_score < game.away_team_score))
          map_season[:win] += 1
        elsif (not away_game and (game.home_team_score < game.away_team_score)) or
            (away_game and (game.home_team_score > game.away_team_score))
          map_season[:lose] += 1
        else
          map_season[:draw] += 1
        end

        # Handle clean sheets
        map_season[:clean_sheets] += 1 if away_game ? (game.home_team_score == 0) : (game.away_team_score == 0)
      end

      def increment_sport_varieties(map_season, result, is_a_coach = false, coach_id = nil)

        # TODO: As a coach, we will use our own record of red/yellow cards, but eventually we could use the
        # calculated team values by removing this line below. This is done to prevent double counting
        # (as the coach also records the total team red/yellow card counts)
        return unless (is_a_coach and result.player_id == coach_id) or not is_a_coach
        return unless result.specialized

            case result.sport
          when 'soccer', 'futsal'
            map_season[:red_cards] += result.specialized[:red_cards] if result.specialized[:red_cards]
            map_season[:yellow_cards] += result.specialized[:yellow_cards] if result.specialized[:yellow_cards]
            map_season[:assists] += result.specialized[:assists] if result.specialized[:assists]
            map_season[:penalty_saves] += result.specialized[:penalty_saves] if result.specialized[:penalty_saves]
        end
      end

      def obtain_all_game_stats(map)
        all_games = { goals: 0, games: 0, team_games: 0, win: 0, lose: 0, draw: 0, assists: 0 }
        map.each do |_season, v|
          all_games[:goals] += v[:goals] || 0
          all_games[:games] += v[:games] || 0
          all_games[:team_games] += v[:team_games] || 0
          all_games[:win] += v[:win] || 0
          all_games[:lose] += v[:lose] || 0
          all_games[:draw] += v[:draw] || 0
          all_games[:red_cards] ||= 0
          all_games[:yellow_cards] ||= 0
          all_games[:assists] ||= 0
          all_games[:penalty_saves] ||= 0
          all_games[:goals_conceded] ||= 0
          all_games[:clean_sheets] ||= 0
          all_games[:team_conceded] ||= 0

          # Specialized stats for soccer
          all_games[:red_cards] += v[:red_cards] || 0 if v[:red_cards]
          all_games[:yellow_cards] += v[:yellow_cards] || 0 if v[:yellow_cards]
          all_games[:assists] += v[:assists] || 0 if v[:assists]
          all_games[:penalty_saves] += v[:penalty_saves] || 0 if v[:penalty_saves]
          all_games[:goals_conceded] += v[:goals_conceded] || 0 if v[:goals_conceded]
          all_games[:clean_sheets] += v[:clean_sheets] || 0 if v[:clean_sheets]
          all_games[:team_conceded] += v[:team_conceded] || 0 if v[:team_conceded]
        end
        all_games
      end

      def obtain_role_varieties(user, team_games, map)
        return {} unless user.active_sport_profile.try(:position) == 'Coach'
        role_stats = {}
        team_games.each do |game|
          season = game.season
          map_season = map[season] || {}

          # Initialize
          map_season[:coached_games] ||= 0

          # Increment
          map_season[:coached_games] += 1
        end
        role_stats
      end

    end
  end
end