require 'active_support/concern'

module Games
  module Csv
    extend ActiveSupport::Concern

    module ClassMethods

      def setup_uniqueness_check
        @unique_name = []
      end

      def load_player_stats(filename, original_csv_mode = false)

        records = []
        batch_size = 100
        count = 0
        new_records = 0
        rand = Random.new(DateTime.current.to_i)

        team_name = team_name_from_filename(filename) if original_csv_mode

        CSV.open(filename, headers: true).each do |row|
          result = each_player_stat(records, row, original_csv_mode, team_name, count, batch_size, new_records)
          if result
            count += batch_size
            new_records = result
          end
        end

        # Save anything outstanding
        ActiveRecord::Base.transaction do
          records.each do |record|
            record.save!
            count += 1
          end
        end

        count
      end

      def each_player_stat(records, row, original_csv_mode, team_name, count, batch_size, new_records)
        # Default sport is soccer
        sport = row['Sport'].try(:strip).try(:downcase) || 'soccer'

        # Get the relevant game
        game = Game.where(ref: row['GameId'].strip, sport: sport).first
        raise "Invalid game with GameId: #{row['GameId']}" unless game

        year = game.start_date.year
        club, team, association = obtain_club_team_assoc(original_csv_mode, team_name, row, sport, year)

        # TODO: Workaround for (junior) in player's name
        names = Namae.parse(row['Name'].gsub(/\(junior\)/, '').strip)

        # TODO: Namae does not like 'Lord' as a direct surname
        a_lord = row['Name'].include?('Lord')

        if names.empty? and not a_lord
          puts "Invalid Name: #{row['Name']}"
          return nil
        end

        # Just split the name for exceptions; otherwise, use the namae results
        given_name = a_lord ? row['Name'].strip.split(' ')[0] : names[0].given
        family_name = a_lord ? row['Name'].strip.split(' ')[1] : names[0].family

        player = User.where(first_name: given_name, last_name: family_name).
                 first_or_initialize(activation_state: 'bulk',
                                     position: row['Number'].try(:strip),
                                     disable_notification: true)
        new_records += 1 unless player.persisted?
        player.club = club if club

        # Update the team and create PreviousTeam records too
        update_player_team(player, team) if team

        # For attributes we don't know, just setup something
        player.assign_attributes(email: "#{given_name}.#{family_name}.#{Random.rand(100_000)}", role: :player,
                                 gender: :unknown_gender) if player.email.nil?

        result = create_result(player, game, row, sport, team)
        player.save!

        records << result

        # Save in batches of records
        return nil unless records.size >= (batch_size * 2)
        puts "... saving records #{count + 1}..#{count + batch_size}"
        ActiveRecord::Base.transaction do
          records.each(&:save!)
          records = []
        end
        new_records
      end

      def update_player_team(player, team)
        if player.team and team.id != player.team.id
          player.update_team(team)
        else
          # First team is always just assigned
          player.team = team
        end
      end

      def load_game_stats(filename, original_csv_mode = false)
        games = []
        count = 0
        skipped = 0
        new_records = 0

        game_year = nil

        team_name = team_name_from_filename(filename) if original_csv_mode

        CSV.open(filename, headers: true).each do |row|
          new_records, skipped, count = each_game_stat(row, filename, new_records, skipped, count, original_csv_mode,
                                                       team_name)
        end

        [count, skipped, new_records]
      end

    private

      def si(x)
        # All data should be set to 0 (if not available)
        x.try(:strip).try(:to_i) || 0
      end

      def si_blank(x)
        # Either an integer, or nil
        x.try(:strip).try(:to_i)
      end

      def obtain_club_team_assoc(original_csv_mode, team_name, row, sport, year)
        if original_csv_mode
          # Load the club and team
          club_name, merged_team_name = get_club_name(row['TeamName'].strip)

          # If we have a merged_team_name then append the league details (from the filename) -
          #   handle Ashburton Blue, Ashburton Gold, etc
          merged_team_name ||= team_name

        else
          club_name = row['ClubName'].try(:strip)
          merged_team_name = row['TeamName'].try(:strip)
        end

        association = row['AssociationId'] ? Association.find(row['AssociationId'].to_i) : Association.first

        # Creates clubs and teams when not found already
        club = Club.where(name: club_name, sport: sport).first_or_create!(association: association)
        team = club.teams.where(name: merged_team_name, sport: sport, year: year).first_or_create!

        [club, team, association]
      end

      def create_result(player, game, row, sport, team)
        result = player.results.where(game_id: game.id).first_or_initialize(
            goals: si(row['Goals']), own_goals: si(row['OwnGoals']),
            subst_on: si(row['SubbedOn']), subst_off: si(row['SubbedOff']),
            played_game: true, sport: sport)

        result.specialized = { red_cards: si(row['RedCards']), yellow_cards: si(row['YellowCards']), assists: 0 }
        result.team = player.team

        # If we can establish the home or away team, then set it
        return result unless team
        setup_home_or_away(game, team, player, result)
        result
      end

      def setup_home_or_away(game, team, player, result)
        if game.away_team and game.away_team.id == team.id
          result.home_or_away = :away_game
        elsif game.home_team and game.home_team.id == team.id
          result.home_or_away = :home_game
        else
          puts "No home or away! player=#{player.email}, team=#{team.id}, game=#{game.id}"
        end
      end

      def each_game_stat(row, filename, new_records, skipped, count, original_csv_mode, team_name)

        # Build a game with the details - firstly, parse the date
        game_date = parse_game_date(row)
        unless game_date
          skipped += 1
          return new_records, skipped, count
        end

        # Ensure we only have a single year per import file
        game_year ||= row['Year'].try(:strip) || game_date.year
        game_season = row['Season'].try(:strip) || game_year

        game_id = row['Id'].try(:strip)
        if @unique_name.include?(game_id)
          Rails.logger.warn "** Not Unique! #{filename}, #{game_id}"
          skipped += 1
          return new_records, skipped, count
        end if game_id
        @unique_name.push game_id if game_id

        # Defaults to Soccer
        sport = row['Sport'].try(:strip).try(:downcase) || 'soccer'

        game, new_records = create_game(row, game_id, sport, game_season, game_date, new_records)

        association = row['AssociationId'] ? Association.find(row['AssociationId'].to_i) : Association.first
        home_club, away_club, home_team_name, away_team_name = obtain_home_and_away_clubs(original_csv_mode, row,
                                                                                          team_name, game, association)
        no_standings = row['NoStanding'] ? row['NoStanding'] == '1' : false

        update_rounds(game, row)
        league = League.where(name: row['League'].strip, sport: game.sport).first_or_create!(assoc: association, no_standings: no_standings)
        update_home_and_away_teams(game, game_year, league, home_club, home_team_name, away_club, away_team_name,
                                   association)
        update_scores_and_game_state(game, row)

        game.save!
        count += 1
        [new_records, skipped, count]
      end

      def parse_game_date(row)
        begin
          game_date = DateTime.strptime(row['GameDate'] + ' +0:00', '%d/%m/%Y %I:%M:%S %P %z') if row['GameDate']
        rescue ArgumentError => ae
        end

        # Second attempt (dd/mm/yy hh:mm, assumes 20xx as the year)
        begin
          game_date = DateTime.strptime(row['GameDate'] + ' +0:00', '%d/%m/%y %H:%M %z') if row['GameDate']
        rescue ArgumentError => ae
          Rails.logger.warn "Invalid Date: '#{row['GameDate']}'; skipping"
          return nil
        end unless game_date
        game_date
      end

      def create_game(row, game_id, sport, game_season, game_date, new_records)
        game = if game_id
                 Game.where(ref: game_id, sport: sport, season: game_season).first_or_initialize
               else
                 Game.new(sport: sport, season: game_season)
               end

        new_records += 1 unless game.persisted?
        game.start_date = game_date
        game.end_date = game_date

        game.venue = ContactDetail.where(address1: row['Venue'].strip).first_or_create!
        [game, new_records]
      end

      def obtain_home_and_away_clubs(original_csv_mode, row, team_name, game, association)

        home_club_name, home_team_name, away_club_name, away_team_name = obtain_names(original_csv_mode, row, team_name)

        # Creates home and away clubs, if not found
        home_club = Club.where(name: home_club_name, sport: game.sport).first_or_create!(assoc: association)
        away_club = Club.where(name: away_club_name, sport: game.sport).first_or_create!(assoc: association)

        [home_club, away_club, home_team_name, away_team_name]
      end

      def obtain_names(original_csv_mode, row, team_name)
        if original_csv_mode
          home_club_name, home_team_name = get_club_name(row['HomeTeamName'].strip)
          away_club_name, away_team_name = get_club_name(row['AwayTeamName'].strip)

          home_team_name ||= team_name
          away_team_name ||= team_name

        else
          home_team_name = row['HomeTeamName'].try(:strip)
          away_team_name = row['AwayTeamName'].try(:strip)
          home_club_name = row['HomeClubName'].try(:strip) || home_team_name
          away_club_name = row['AwayClubName'].try(:strip) || away_team_name
        end
        [home_club_name, home_team_name, away_club_name, away_team_name]
      end

      def update_rounds(game, row)
        round = row['Round'].strip
        round_id = round.gsub(/^.*Round\s+(\d+)/, '\1').to_i
        game.round = round_id if round_id > 0
        game.round_str = "Round #{game.round}" if round_id > 0

        unless game.round
          # Handle catch up rounds
          if round.starts_with?('Catch Up') or round.starts_with?('Catch-Up')
            game.round = 'CU'
            game.round_str = 'Catch Up Round'
          end
        end
      end

      def update_home_and_away_teams(game, game_year, league, home_club, home_team_name, away_club, away_team_name,
                                     association)

        # Creates home and away teams if not found
        home_team = home_club.teams.where(name: home_team_name, league: league, year: game_year, sport: game.sport).
                    first_or_create!(assoc: association, display_state: Team.display_states[:not_club_name])
        away_team = away_club.teams.where(name: away_team_name, league: league, year: game_year, sport: game.sport).
                    first_or_create!(assoc: association, display_state: Team.display_states[:not_club_name])

        game.home_team = home_team
        game.away_team = away_team
      end

      def update_scores_and_game_state(game, row)
        game.home_team_score = si_blank(row['HomeTeamScore'])
        game.away_team_score = si_blank(row['AwayTeamScore'])
        game.state = :final_score if game.home_team_score and game.away_team_score
        game.state ||= :not_started if game.start_date > DateTime.current
        game.state ||= :played if game.start_date < DateTime.current
        game.state ||= :commenced if game.start_date == DateTime.current
      end

      def team_name_from_filename(filename)
        # parse the filename, remove the year and '-Players' if required (e.g. "2013-XYZ club-Players.csv" )
        File.basename(filename, '.csv').gsub(/^\d+\-/, '').gsub(/\-Players/, '')
      end

      def get_club_name(name)
        case name
        when 'Albert Park SC' then return 'Albert Park SC', nil
        when 'Alexandra Junior SC' then return 'Alexandra Junior SC', nil
        when 'Alphington SC' then return 'Alphington SC', nil
        when 'Altona City SC' then return 'Altona City SC', nil
        when 'Altona City SC Maroon' then return 'Altona City SC', 'Maroon'
        when 'Altona City SC Yellow' then return 'Altona City SC', 'Yellow'
        when 'Altona East Phoenix SC' then return 'Altona East Phoenix SC', nil
        when 'Altona Lions SC' then return 'Altona Lions SC', nil
        when 'Altona Magic SC' then return 'Altona Magic SC', nil
        when 'Altona North SC' then return 'Altona North SC', nil
        when 'Ashburton United SC' then return 'Ashburton United SC', nil
        when 'Ashburton United SC Green' then return 'Ashburton United SC', 'Green'
        when 'Ashburton United SC Yellow' then return 'Ashburton United SC', 'Yellow'
        when 'Ashburton Womens SC' then return 'Ashburton Womens SC', nil
        when 'Aspendale SC' then return 'Aspendale SC', nil
        when 'Aston Athletic FC' then return 'Aston Athletic FC', nil
        when 'Avondale FC' then return 'Avondale FC', nil
        when 'Avondale Heights S.C.' then return 'Avondale Heights SC', nil
        when 'Avondale Heights SC' then return 'Avondale Heights SC', nil
        when 'Ballarat Red Devils SC' then return 'Ballarat Red Devils SC', nil
        when 'Ballarat SC' then return 'Ballarat SC', nil
        when 'Balmoral FC' then return 'Balmoral FC', nil
        when 'Banyule City SC' then return 'Banyule City SC', nil
        when 'Baxter SC' then return 'Baxter SC', nil
        when 'Bayside Argonauts FC' then return 'Bayside Argonauts FC', nil
        when 'Beaumaris SC' then return 'Beaumaris SC', nil
        when 'Bell Park SC' then return 'Bell Park SC', nil
        when 'Bendigo City FC' then return 'Bendigo City FC', nil
        when 'Bentleigh Greens SC' then return 'Bentleigh Greens SC', nil
        when 'Berwick City SC' then return 'Berwick City SC', nil
        when 'Berwick City SC Res' then return 'Berwick City SC', 'Reserves'
        when 'Boroondara Eagles FC' then return 'Boroondara Eagles FC', nil
        when 'Boroondara Eagles FC Boys 10  Joeys Purple' then return 'Boroondara Eagles FC', 'Boys 10 Joeys Purple'
        when 'Boroondara Eagles FC Boys 10 Joeys Gold' then return 'Boroondara Eagles FC', 'Boys 10 Joeys Gold'
        when 'Boroondara Eagles FC Boys 10 Kangas Gold' then return 'Boroondara Eagles FC', 'Boys 10 Kangas Gold'
        when 'Boroondara Eagles FC Boys 10 Kangas Purple' then return 'Boroondara Eagles FC', 'Boys 10 Kangas Purple'
        when 'Boroondara Eagles FC Boys 11 Wallabies' then return 'Boroondara Eagles FC', 'Boys 11 Wallabies'
        when 'Boroondara Eagles FC Boys 9 Kangas Gold' then return 'Boroondara Eagles FC', 'Boys 9 Kangas Gold'
        when 'Boroondara Eagles FC Boys 9 Kangas Purple' then return 'Boroondara Eagles FC', 'Boys 9 Kangas Purple'
        when 'Boroondara Eagles FC Girls 10 Wallabies' then return 'Boroondara Eagles FC', 'FC Girls 10 Wallabies'
        when 'Boroondara Eagles FC Girls 11 Kan/Wall Gold' then return 'Boroondara Eagles FC', 'Girls 11 Kan/Wall Gold'
        when 'Boroondara Eagles FC Girls 11 Kan/Wall Purple'
          return 'Boroondara Eagles FC', 'Girls 11 Kan/Wall Purple'
        when 'Boroondara Eagles FC WPL' then return 'Boroondara Eagles FC', 'WPL'
        when 'Boroondara Eagles FC WPL Reserves' then return 'Boroondara Eagles FC', 'WPL Reserves'
        when 'Box Hill United Pythagoras SC' then return 'Box Hill United Pythagoras SC', nil
        when 'Box Hill United SC' then return 'Box Hill United SC', nil
        when 'Box Hill United SC Blue' then return 'Box Hill United SC', 'Blue'
        when 'Box Hill United SC Silver' then return 'Box Hill United SC', 'Silver'
        when 'Brandon Park SC' then return 'Brandon Park SC', nil
        when 'Brighton Blue Foxes' then return 'Brighton Blue Foxes', nil
        when 'Brighton City' then return 'Brighton City', nil
        when 'Brighton Dragons' then return 'Brighton Dragons', nil
        when 'Brighton SC' then return 'Brighton SC', nil
        when 'Brighton SC Blue Galaxy' then return 'Brighton SC', 'Blue Galaxy'
        when 'Brighton SC Firsts' then return 'Brighton SC', 'Firsts'
        when 'Brighton SC Seconds' then return 'Brighton SC', 'Seconds'
        when 'Brighton United' then return 'Brighton United', nil
        when 'Brimbank Stallions FC' then return 'Brimbank Stallions FC', nil
        when 'Brunswick City SC' then return 'Brunswick City SC', nil
        when 'Brunswick Zebras FC' then return 'Brunswick Zebras FC', nil
        when 'Bundoora United FC' then return 'Bundoora United FC', nil
        when 'Bye' then return 'Bye', nil
        when 'Cairnlea FC' then return 'Cairnlea FC', nil
        when 'Cairnlea FC Mens State League Div 1' then return 'Cairnlea FC', 'Mens State League Div 1'
        when 'Cairnlea FC Red' then return 'Cairnlea FC', 'Red'
        when 'Cairnlea FC White' then return 'Cairnlea FC', 'White'
        when 'Casey Comets FC' then return 'Casey Comets FC', nil
        when 'Casey Panthers SC' then return 'Casey Panthers SC', nil
        when 'Caulfield United Cobras SC' then return 'Caulfield United Cobras SC', nil
        when 'Chelsea FC' then return 'Chelsea FC', nil
        when 'Chelsea Meerkats' then return 'Chelsea FC', 'Meerkats'
        when 'Chisholm United FC' then return 'Chisholm United FC', nil
        when 'Clarinda United FC' then return 'Clarinda United FC', nil
        when 'Collingwood City FC' then return 'Collingwood City FC', nil
        when 'Corio SC' then return 'Corio SC', nil
        when 'Croydon City Arrows SC' then return 'Croydon City Arrows SC', nil
        when 'Croydon City Arrows SC Green' then return 'Croydon City Arrows SC', 'Green'
        when 'Croydon City Arrows SC Old Boys' then return 'Croydon City Arrows SC', 'Old Boys'
        when 'Croydon City Arrows SC Red' then return 'Croydon City Arrows SC', 'Red'
        when 'Dandenong City SC' then return 'Dandenong City SC', nil
        when 'Dandenong South SC' then return 'Dandenong South SC', nil
        when 'Dandenong Thunder SC' then return 'Dandenong Thunder SC', nil
        when 'Darebin Falcons Womens SC Blue' then return 'Darebin Falcons Womens SC', 'Blue'
        when 'Darebin Falcons Womens SC Red' then return 'Darebin Falcons Womens SC', 'Red'
        when 'Darebin United SC' then return 'Darebin United SC', nil
        when 'Diamond Valley United SC' then return 'Diamond Valley United SC', nil
        when 'Dingley Stars FC' then return 'Dingley Stars FC', nil
        when 'Doncaster Rovers SC' then return 'Doncaster Rovers SC', nil
        when 'Doncaster Rovers SC Orange' then return 'Doncaster Rovers SC', 'Orange'
        when 'Doncaster Rovers SC Yellow' then return 'Doncaster Rovers SC', 'Yellow'
        when 'Doveton SC' then return 'Doveton SC', nil
        when 'East Bentleigh Strikers' then return 'East Bentleigh Strikers SC', nil
        when 'East Bentleigh Strikers SC' then return 'East Bentleigh Strikers SC', nil
        when 'East Brighton United FC' then return 'East Brighton United FC', nil
        when 'Eastern Lions SC' then return 'Eastern Lions SC', nil
        when 'Eltham Redbacks FC' then return 'Eltham Redbacks FC', nil
        when 'Eltham Redbacks FC Blue' then return 'Eltham Redbacks FC', 'Blue'
        when 'Eltham Redbacks FC Red' then return 'Eltham Redbacks FC', 'Red'
        when 'Elwood City SC' then return 'Elwood City SC', nil
        when 'Endeavour Hills Fire SC' then return 'Endeavour Hills Fire SC', nil
        when 'Endeavour United SC' then return 'Endeavour United SC', nil
        when 'Epping City SC' then return 'Epping City SC', nil
        when 'Essendon Royals SC' then return 'Essendon Royals SC', nil
        when 'Essendon United FC' then return 'Essendon United FC', nil
        when 'FC Bendigo' then return 'FC Bendigo', nil
        when 'FC Bulleen Lions' then return 'FC Bulleen Lions', nil
        when 'FC Bulleen Lions Gold' then return 'FC Bulleen Lions', 'Gold'
        when 'FC Clifton Hill' then return 'FC Clifton Hill', nil
        when 'FC Strathmore' then return 'FC Strathmore', nil
        when 'FFV Game Training' then return 'FFV Game Training', nil
        when 'FFV NTC Boys 15s' then return 'FFV NTC Boys 15s', nil
        when 'FFV State Under 13 Girls' then return 'FFV State Under 13 Girls', nil
        when 'FFV Under 15 Girls' then return 'FFV Under 15 Girls', nil
        when 'Fawkner Blues - Reserves' then return 'Fawkner Blues FC', 'Reserves'
        when 'Fawkner Blues FC' then return 'Fawkner Blues FC', nil
        when 'Fawkner SC' then return 'Fawkner SC', nil
        when 'Fitzroy City SC' then return 'Fitzroy City SC', nil
        when 'Frankston Pines FC' then return 'Frankston Pines FC', nil
        when 'Geelong Rangers SC' then return 'Geelong Rangers SC', nil
        when 'Geelong SC' then return 'Geelong SC', nil
        when 'Gisborne SC' then return 'Gisborne SC', nil
        when 'Gisborne Soccer Club' then return 'Gisborne SC', nil
        when 'Glen Waverley SC' then return 'Glen Waverley SC', nil
        when 'Glen Waverley u10 Gunners' then return 'Glen Waverley SC', 'u10 Gunners'
        when 'Glen Waverley u10 Sharks' then return 'Glen Waverley SC', 'u10 Sharks'
        when 'Glen Waverley u10 United' then return 'Glen Waverley SC', 'u10 United'
        when 'Glen Waverley u11 Scorpions' then return 'Glen Waverley SC', 'u11 Scorpions'
        when 'Glen Waverley u9 Cheetahs' then return 'Glen Waverley SC', 'u9 Cheetahs'
        when 'Glen Waverley u9 Storm' then return 'Glen Waverley SC', 'u9 Storm'
        when 'Goulburn Valley Suns FC' then return 'Goulburn Valley Suns FC', nil
        when 'Green Gully SC' then return 'Green Gully SC', nil
        when 'Greenvale United SC' then return 'Greenvale United SC', nil
        when 'Hampton Junior SC Vixens' then return 'Hampton Junior SC Vixens', nil
        when 'Hampton Park United Sparrows FC' then return 'Hampton Park United Sparrows FC', nil
        when 'Harrisfield Hurricanes SC' then return 'Harrisfield Hurricanes SC', nil
        when 'Healesville SC' then return 'Healesville SC', nil
        when 'Heatherton United SC' then return 'Heatherton United SC', nil
        when 'Heidelberg Eagles SC' then return 'Heidelberg Eagles SC', nil
        when 'Heidelberg Stars SC' then return 'Heidelberg Stars SC', nil
        when 'Heidelberg United FC' then return 'Heidelberg United FC', nil
        when 'Heidelberg United SC' then return 'Heidelberg United SC', nil
        when 'Hoppers Crossing SC' then return 'Hoppers Crossing SC', nil
        when 'Hume City FC' then return 'Hume City FC', nil
        when 'Hume United FC' then return 'Hume United FC', nil
        when 'Junior NTC' then return 'Junior NTC', nil
        when 'Juventus Old Boys SC' then return 'Juventus Old Boys SC', nil
        when 'Keilor Park SC' then return 'Keilor Park SC', nil
        when 'Keilor Park SC Blue (Eagles)' then return 'Keilor Park SC', 'Blue (Eagles)'
        when 'Keilor Wolves SC' then return 'Keilor Wolves SC', nil
        when 'Kensington Junior Girls SC' then return 'Kensington Junior Girls SC', nil
        when 'Kensington Junior Girls SC Blue' then return 'Kensington Junior Girls SC', 'Blue'
        when 'Kensington Junior Girls SC Gold' then return 'Kensington Junior Girls SC', 'Gold'
        when 'Keon Park SC' then return 'Keon Park SC', nil
        when 'Keysborough SC' then return 'Keysborough SC', nil
        when 'Kings Domain FC' then return 'Kings Domain FC', nil
        when 'Kingston City FC' then return 'Kingston City FC', nil
        when 'Knox City FC' then return 'Knox City FC', nil
        when 'Kyneton District SC' then return 'Kyneton District SC', nil
        when 'La Trobe University SC' then return 'La Trobe University SC', nil
        when 'Lalor United FC' then return 'Lalor United FC', nil
        when 'Langwarrin SC' then return 'Langwarrin SC', nil
        when 'Langwarrin SC Blue' then return 'Langwarrin SC', 'Blue'
        when 'Lara SC' then return 'Lara SC', nil
        when 'Laverton Park SC' then return 'Laverton Park SC', nil
        when 'Lilydale Eagles SC' then return 'Lilydale Eagles SC', nil
        when 'Lyndale United SC' then return 'Lyndale United SC', nil
        when 'Malvern City FC' then return 'Malvern City FC', nil
        when 'Manningham United Blues FC' then return 'Fawkner Blues FC', 'Manningham United Blues FC'
        when 'Manningham United Football Club' then return 'Fawkner Blues FC', 'Manningham United Football Club'
        when 'Marcellin Old Collegians SC' then return 'Marcellin Old Collegians SC', nil
        when 'Maribyrnong Greens SC' then return 'Maribyrnong Greens SC', nil
        when 'Mazenod United FC' then return 'Mazenod United FC', nil
        when 'Meadow Park Eagles SC' then return 'Meadow Park Eagles SC', nil
        when 'Melbourne City' then return 'Melbourne City', nil
        when 'Melbourne City FC' then return 'Melbourne City FC', nil
        when 'Melbourne Knights FC' then return 'Melbourne Knights FC', nil
        when 'Melbourne Lions SC' then return 'Melbourne Lions SC', nil
        when 'Melbourne University SC' then return 'Melbourne University SC', nil
        when 'Melbourne Victory' then return 'Melbourne Victory', nil
        when 'Melton Phoenix FC' then return 'Melton Phoenix FC', nil
        when 'Middle Park FC' then return 'Middle Park FC', nil
        when 'Mill Park SC' then return 'Mill Park SC', nil
        when 'Mitchell Rangers SC' then return 'Mitchell Rangers SC', nil
        when 'Monash City SC' then return 'Monash City SC', nil
        when 'Monash University SC' then return 'Monash University SC', nil
        when 'Monbulk Rangers SC' then return 'Monbulk Rangers SC', nil
        when 'Montrose SC' then return 'Montrose SC', nil
        when 'Mooroolbark Junior SC' then return 'Mooroolbark SC', 'Junior'
        when 'Mooroolbark SC' then return 'Mooroolbark SC', nil
        when 'Mooroolbark Senior SC' then return 'Mooroolbark SC', 'Senior'
        when 'Moreland City SC' then return 'Moreland City SC', nil
        when 'Moreland United SC' then return 'Moreland United SC', nil
        when 'Moreland Zebras FC' then return 'Moreland Zebras FC', nil
        when 'Moreland Zebras/Moreland Youth' then return 'Moreland Zebras FC', 'Moreland Youth'
        when 'Mornington SC' then return 'Mornington SC', nil
        when 'Morwell Pegasus SC' then return 'Morwell Pegasus SC', nil
        when 'Mt Lilydale Old Collegians SC' then return 'Mt Lilydale Old Collegians SC', nil
        when 'Murray United FC' then return 'Murray United FC', nil
        when 'NCJFC Girls U10/11 2014' then return 'NCJFC Girls U10/11 2014', nil
        when 'Newmarket Phoenix FC' then return 'Newmarket Phoenix FC', nil
        when 'Noble Park SC' then return 'Noble Park SC', nil
        when 'Noble Park United FC' then return 'Noble Park United FC', nil
        when 'NodeNotFound' then return 'NodeNotFound', nil
        when 'North Caulfield Senior FC' then return 'North Caulfield Senior FC', nil
        when 'North City Wolves FC' then return 'North City Wolves FC', nil
        when 'North Geelong Warriors FC' then return 'North Geelong Warriors FC', nil
        when 'North Geelong Warriors SC' then return 'North Geelong Warriors SC', nil
        when 'North Sunshine Eagles SC' then return 'North Sunshine Eagles SC', nil
        when 'Northcote City FC' then return 'Northcote City FC', nil
        when 'Northern Falcons SC' then return 'Northern Falcons SC', nil
        when 'Northern United SC' then return 'Northern United SC', nil
        when 'Nunawading City FC' then return 'Nunawading City FC', nil
        when 'Oakleigh Cannons FC' then return 'Oakleigh Cannons FC', nil
        when 'Old Camberwell Grammarians SC' then return 'Old Camberwell Grammarians SC', nil
        when 'Old Carey SC' then return 'Old Carey SC', nil
        when 'Old Ivanhoe Grammarians SC' then return 'Old Ivanhoe Grammarians SC', nil
        when 'Old Melburnians SC' then return 'Old Melburnians SC', nil
        when 'Old Mentonians SC' then return 'Old Mentonians SC', nil
        when 'Old Scotch SC' then return 'Old Scotch SC', nil
        when 'Old Trinity Grammarians SC' then return 'Old Trinity Grammarians SC', nil
        when 'Old Xaverians SC' then return 'Old Xaverians SC', nil
        when 'Parkmore SC' then return 'Parkmore SC', nil
        when 'Pascoe Vale SC' then return 'Pascoe Vale SC', nil
        when 'Peninsula Strikers Junior FC' then return 'Peninsula Strikers FC', 'Junior'
        when 'Peninsula Strikers Senior FC' then return 'Peninsula Strikers FC', 'Senior'
        when 'Plenty Valley Lions FC' then return 'Plenty Valley Lions FC', nil
        when 'Point Cook FC' then return 'Point Cook FC', nil
        when 'Port Melbourne Sharks SC' then return 'Port Melbourne Sharks SC', nil
        when 'Prahran City Football Club' then return 'Prahran City Football Club', nil
        when 'Preston Lions FC' then return 'Preston Lions FC', nil
        when 'RMIT FC' then return 'RMIT FC', nil
        when 'Reservoir Yeti SC' then return 'Reservoir Yeti SC', nil
        when 'Richmond FC' then return 'Richmond FC', nil
        when 'Richmond SC' then return 'Richmond FC', nil # 'Richmond SC'
        when 'Richmond SC Seniors' then return 'Richmond FC', 'Richmond SC Seniors'
        when 'Richmond SC U18 NPL' then return 'Richmond FC', 'Richmond SC U18 NPL'
        when 'Ringwood City FC' then return 'Ringwood City FC', nil
        when 'Ringwood City FC Blue' then return 'Ringwood City FC', 'Blue'
        when 'Ringwood City FC Orange' then return 'Ringwood City FC', 'Orange'
        when 'Ringwood City FC White' then return 'Ringwood City FC', 'White'
        when 'Riversdale SC' then return 'Riversdale SC', nil
        when 'Rosebud Heart SC' then return 'Rosebud Heart SC', nil
        when 'Rowville Eagles SC' then return 'Rowville Eagles SC', nil
        when 'Sandown Lions FC' then return 'Sandown Lions FC', nil
        when 'Sandringham SC' then return 'Sandringham SC', nil
        when 'Seaford United SC' then return 'Seaford United SC', nil
        when 'Sebastopol Vikings SC' then return 'Sebastopol Vikings SC', nil
        when 'Senior NTC' then return 'Senior NTC', nil
        when 'Skilleroos Gold' then return 'Skilleroos', 'U14 NPL East (Gold)'
        when 'Skilleroos Green' then return 'Skilleroos', 'U13 NPL East (Green)'
        when 'Skye United FC' then return 'Skye United FC', nil
        when 'Skye United FC Blue' then return 'Skye United FC', 'Blue'
        when 'South Melbourne FC' then return 'South Melbourne FC', nil
        when 'South Melbourne Womens FC' then return 'South Melbourne FC', 'Womens'
        when 'South Springvale SC' then return 'South Springvale SC', nil
        when 'South Yarra SC' then return 'South Yarra SC', nil
        when 'South Yarra SC Red' then return 'South Yarra SC', 'Red'
        when 'Southern Stars FC' then return 'Southern Stars FC', nil
        when 'Sporting Carlton SC' then return 'Sporting Carlton SC', nil
        when 'Sporting Whittlesea FC' then return 'Sporting Whittlesea FC', nil
        when 'Spring Hills FC' then return 'Spring Hills FC', nil
        when 'Spring Hills FC Purple' then return 'Spring Hills FC', 'Purple'
        when 'Spring Hills FC Red' then return 'Spring Hills FC', 'Red'
        when 'Springvale City SC' then return 'Springvale City SC', nil
        when 'Springvale White Eagles FC' then return 'Springvale White Eagles FC', nil
        when 'St Albans Saints SC' then return 'St Albans Saints SC', nil
        when 'St Kevins Old Boys SC' then return 'St Kevins Old Boys SC', nil
        when 'St Kilda SC' then return 'St Kilda SC', nil
        when 'Sunbury United FC' then return 'Sunbury United FC', nil
        when 'Sunbury United Junior SC' then return 'Sunbury United Junior SC', nil
        when 'Sunshine George Cross SC' then return 'Sunshine George Cross SC', nil
        when 'Surf Coast FC' then return 'Surf Coast FC', nil
        when 'Swinburne FC Reserves' then return 'Swinburne University FC', 'Reserves'
        when 'Swinburne University FC' then return 'Swinburne University FC', nil
        when 'Sydenham Park SC' then return 'Sydenham Park SC', nil
        when 'Sydenham Park SC-Reserves' then return 'Sydenham Park SC', 'Reserves'
        when 'Sydenham Park SC-Seniors' then return 'Sydenham Park SC', 'Seniors'
        when 'Templestowe United FC' then return 'Templestowe United FC', nil
        when 'Templestowe United FC Gold' then return 'Templestowe United FC', 'Gold'
        when 'Templestowe United FC Maroon' then return 'Templestowe United FC', 'Maroon'
        when 'Templestowe United FC Red' then return 'Templestowe United FC', 'Red'
        when 'Truganina Hornets SC' then return 'Truganina SC', 'Hornets'
        when 'Truganina SC' then return 'Truganina SC', nil
        when 'University of Melbourne SC' then return 'University of Melbourne SC', nil
        when 'Upfield SC' then return 'Upfield SC', nil
        when 'Warragul United SC' then return 'Warragul United SC', nil
        when 'Watsonia Heights FC' then return 'Watsonia Heights FC', nil
        when 'Watsonia Heights FC U11 Girls' then return 'Watsonia Heights FC', 'U11 Girls'
        when 'Waverley Victory FC' then return 'Waverley Victory FC', nil
        when 'Waverley Victory Football Club' then return 'Waverley Victory FC', nil
        when 'Waverley Wanderers SC' then return 'Waverley Wanderers SC', nil
        when 'Werribee City FC' then return 'Werribee City FC', nil
        when 'West Preston SC' then return 'West Preston SC', nil
        when 'Western Eagles SC' then return 'Western Eagles SC', nil
        when 'Western Suburbs SC' then return 'Western Suburbs SC', nil
        when 'Westgate FC' then return 'Westgate FC', nil
        when 'Westside Strikers Caroline Springs FC' then return 'Westside Strikers Caroline Springs FC', nil
        when 'Westvale SC' then return 'Westvale SC', nil
        when 'White Star Dandenong SC' then return 'White Star Dandenong SC', nil
        when 'Whitehorse United SC' then return 'Whitehorse United SC', nil
        when 'Whitehorse United SC Blue' then return 'Whitehorse United SC', 'Blue'
        when 'Whitehorse United SC Yellow' then return 'Whitehorse United SC', 'Yellow'
        when 'Whittlesea Ranges FC' then return 'Whittlesea Ranges FC', nil
        when 'Whittlesea United SC' then return 'Whittlesea United SC', nil
        when 'Williamstown SC' then return 'Williamstown SC', nil
        when 'Yarra Jets FC' then return 'Yarra Jets FC', nil
        when 'Yarra Jets FC (Girls U11 Wallabies)' then return 'Yarra Jets FC', 'Girls U11 Wallabies'
        when 'Yarra Jets FC (Girls U9 Joeys SC)' then return 'Yarra Jets FC', 'Girls U9 Joeys SC'
        when 'Yarra Jets FC Blue (Girls U11 Joeys)' then return 'Yarra Jets FC', 'Girls U11 Joeys'
        when 'Yarra Jets FC Red (Girls U9 Joeys)' then return 'Yarra Jets FC', 'Girls U9 Joeys'
        when 'Yarraville FC' then return 'Yarraville FC', nil
        when 'Yarraville FC Reserves' then return 'Yarraville FC', 'Reserves'
        when 'Yarraville FC U16B' then return 'Yarraville FC', 'U16B'
        when 'YarravilleFC Seniors' then return 'Yarraville FC', 'Seniors'

        when 'Ashburton Blue' then return 'Ashburton United SC', 'Blue'
        when 'Ashburton Gold' then return 'Ashburton United SC', 'Gold'
        when 'Ashburton Green' then return 'Ashburton United SC', 'Green'
        when 'Ashburton Grey' then return 'Ashburton United SC', 'Grey'
        when 'Ashburton Purple' then return 'Ashburton United SC', 'Purple'
        when 'Ashburton Red' then return 'Ashburton United SC', 'Red'
        when 'Ashburton United SC' then return 'Ashburton United SC', nil
        when 'Ashburton Yellow' then return 'Ashburton United SC', 'Yellow'
        when 'Aston Athletic FC' then return 'Aston Athletic FC', nil
        when 'Banyule City SC' then return 'Banyule City SC', nil
        when 'Boroondara Eagles FC' then return 'Boroondara Eagles FC', nil
        when 'Brandon Park SC' then return 'Brandon Park SC', nil
        when 'Bundoora United FC' then return 'Bundoora United FC', nil
        when 'Casey Comets FC' then return 'Casey Comets FC', nil
        when 'Casey Comets FC WPL' then return 'Casey Comets FC', 'WPL'
        when 'Caulfield United Cobras SC' then return 'Caulfield United SC', 'Cobras'
        when 'Chisholm United FC' then return 'Chisholm United FC', nil
        when 'Chisholm United FC Blue' then return 'Chisholm United FC', 'Blue'
        when 'Diamond Valley United SC' then return 'Diamond Valley United SC', nil
        when 'Doncaster Rovers SC' then return 'Doncaster Rovers SC', nil
        when 'East Kew JFC' then return 'East Kew JFC', nil
        when 'East Kew JFC Red' then return 'East Kew JFC', 'Red'
        when 'East Kew Junior FC' then return 'East Kew Junior FC', nil
        when 'Essendon Royals SC' then return 'Essendon Royals SC', nil
        when 'Essendon United FC' then return 'Essendon United FC', nil
        when 'Fawkner Blues FC' then return 'Fawkner Blues FC', nil
        when 'Fitzroy City SC' then return 'Fitzroy City SC', nil
        when 'Geelong SC' then return 'Geelong SC', nil
        when 'Glen Waverley SC FrankC' then return 'Glen Waverley SC', 'FrankC'
        when 'Glen Waverley SC RP' then return 'Glen Waverley SC', 'RP'
        when 'Heidelberg Stars SC' then return 'Heidelberg Stars SC', nil
        when 'Heidelberg United SC' then return 'Heidelberg United SC', nil
        when 'Hume United FC' then return 'Hume United FC', nil
        when 'Junior NTC' then return 'Junior NTC', nil
        when 'Knox United SC' then return 'Knox United SC', nil
        when 'Mazenod United FC' then return 'Mazenod United FC', nil
        when 'Mazenod United FC Blue' then return 'Mazenod United FC', 'Blue'
        when 'Mazenod United FC Silver' then return 'Mazenod United FC', 'Silver'
        when 'Melbourne University SC' then return 'Melbourne University SC', nil
        when 'Middle Park FC' then return 'Middle Park FC', nil
        when 'Monash City SC' then return 'Monash City SC', nil
        when 'Mooroolbark SC' then return 'Mooroolbark SC', nil
        when 'Moreland United SC' then return 'Moreland United SC', nil
        when 'Mount Waverley City SC' then return 'Mount Waverley City SC', nil
        when 'Mount Waverley City SC Red' then return 'Mount Waverley City SC', 'Red'
        when 'North Caulfield Junior FC Orange' then return 'North Caulfield Junior FC', 'Orange'
        when 'North Caulfield Junior FC Tigers' then return 'North Caulfield Junior FC', 'Tigers'
        when 'Old Melburnians SC Blue' then return 'Old Melburnians SC', 'Blue'
        when 'Old Melburnians SC Green' then return 'Old Melburnians SC', 'Green'
        when 'Old Melburnians SC Red' then return 'Old Melburnians SC', 'Red'
        when 'Point Cook FC' then return 'Point Cook FC', nil
        when 'Ringwood City FC' then return 'Ringwood City FC', nil
        when 'Sandringham SC' then return 'Sandringham SC', nil
        when 'Senior NTC' then return 'Senior NTC', nil
        when 'South Yarra SC' then return 'South Yarra SC', nil
        when 'Sporting Whittlesea FC' then return 'Sporting Whittlesea FC', nil
        when 'Sunbury United Junior SC' then return 'Sunbury United Junior SC', nil
        when 'Watsonia Heights FC' then return 'Watsonia Heights FC', nil
        when 'Waverley Victory FC' then return 'Waverley Victory FC', nil
        when 'Westvale SC' then return 'Westvale SC', nil
        when 'Whitehorse United SC' then return 'Whitehorse United SC', nil
        when 'Wonga Park Wizards Under 10 Wallabies' then return 'Wonga Park Wizards', 'Under 10 Wallabies'
        when 'Wonga Park Wizards Under 13B' then return 'Wonga Park Wizards', 'Under 13B'
        when 'Wonga Park Wizards Under 15C' then return 'Wonga Park Wizards', 'Under 15C'
        when 'Yarraville FC' then return 'Yarraville FC', nil
        when 'Yarraville FC Seniors' then return 'Yarraville FC', 'Seniors'
        else # rubocop:disable Style/EmptyElse
        end

        name
      end
    end
  end
end
