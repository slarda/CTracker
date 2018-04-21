class Team < ActiveRecord::Base

  # Display state determines how team names are shown within the app in combination with club and league names
  #
  # not_club_name: Show team name if it doesn't match the club name
  # not_league_name: Show team name if it doesn't match the league name
  # always_display: Always complement the club or league name with the team name
  # never_display: Just show the club or league name
  # team_only: Show the team name only
  #
  # See `augmented_league_name` and `augmented_club_name` below
  #
  enum display_state: { not_club_name: 1, not_league_name: 2, always_display: 3, never_display: 4, team_only: 5 }

  # Associations
  belongs_to :assoc, class_name: 'Association', foreign_key: 'association_id'
  belongs_to :club
  belongs_to :league
  belongs_to :division
  has_many :players,    class_name: 'User', dependent: :nullify
  has_many :home_games, class_name: 'Game', foreign_key: 'home_team_id', dependent: :destroy
  has_many :away_games, class_name: 'Game', foreign_key: 'away_team_id', dependent: :destroy
  has_many :player_results, dependent: :nullify
  has_many :previous_teams

  # Callbacks
  before_create :link_associations
  before_update :decrement_league_counts, if: :league_id_changed?
  after_save :increment_league_counts
  after_destroy :decrement_league_counts

  def augmented_league_name
    case display_state
      when 'not_club_name' then league.name + (club.name != name ? " [#{name}]" : '')
      when 'not_league_name' then (league.name != name) ? "#{league.name} [#{name}]" : name
      when 'always_display' then "#{league.name} [#{name}]"
      when 'never_display' then league.name
      when 'team_only' then name
    end
  end

  def augmented_club_name
    case display_state
      when 'not_club_name' then (club.name != name) ? "#{club.name} [#{name}]" : name
      when 'not_league_name' then club.name + (league.name != name ? " [#{name}]" : '')
      when 'always_display' then "#{club.name} [#{name}]"
      when 'never_display' then club.name
      when 'team_only' then name
    end
  end

  def games
    Game.games(id)
  end

  def next_game(sport)
    future_games(sport).limit(1).first
  end

  def last_game(sport)
    past_games(sport).limit(1).first
  end

  def future_games(sport)
    if sport == 'all'
      Game.includes([{ home_team: [:league, :club, :assoc] }, { away_team: [:league, :club, :assoc] }, { player_results: [:team] }, :venue]).all_future.games(id)
    else
      Game.includes([{ home_team: [:league, :club, :assoc] }, { away_team: [:league, :club, :assoc] }, { player_results: [:team] }, :venue]).future(sport).games(id)
    end
  end

  def past_games(sport)
    if sport == 'all'
      Game.includes([{home_team: [:league, :club, :assoc]}, { away_team: [:league, :club, :assoc]}, { player_results: [:team] }]).all_past.games(id)
    else
      Game.includes([{home_team: [:league, :club, :assoc]}, { away_team: [:league, :club, :assoc]}, { player_results: [:team] }]).past(sport).games(id)
    end
  end

  def self.all_games_for_teams(teams, season)
    home_games = Game.where(home_team_id: teams.pluck(:id), season: season).all
    away_games = Game.where(away_team_id: teams.pluck(:id), season: season).all
    home_games | away_games
  end

private

  def link_associations
    self.assoc = club.assoc if club
  end

  def increment_league_counts
    return unless league and club
    duplicate_teams = Team.unscoped.where(league_id: league_id, club_id: club_id, year: year, sport: sport)
    duplicate_teams.update_all(league_count: duplicate_teams.count)
  end

  def decrement_league_counts
    return unless league and club
    duplicate_teams = Team.where('league_id = ? AND club_id = ? AND id <> ?', league_id_was, club_id_was, self.id)
    duplicate_teams.update_all(league_count: duplicate_teams.count)
  end
end
