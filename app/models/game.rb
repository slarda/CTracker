class Game < ActiveRecord::Base

  # Constants
  enum state: { not_started: 0, commenced: 1, extra_time: 2, played: 3, final_score: 4 }

  # Associations
  belongs_to :assoc,          class_name: 'Association', foreign_key: 'association_id'
  belongs_to :home_team,      class_name: 'Team'
  belongs_to :away_team,      class_name: 'Team'
  belongs_to :venue,          class_name: 'ContactDetail'
  has_many :player_results,   class_name: 'PlayerResult', foreign_key: 'game_id', source: :game,  dependent: :nullify
  has_many :players, through: :player_results, source: :player
  has_many :game_links, as: :linked_to

  # Scopes
  scope :games,   ->(team_id)         { Game.where('home_team_id = ? OR away_team_id = ?', team_id, team_id).includes(:venue) }
  scope :future,  ->(sport)           { where('start_date >= ? AND games.sport=?' , DateTime.current, sport).order('start_date ASC').includes(:venue) }
  scope :past,    ->(sport)           { where('start_date < ? AND games.sport=?' , DateTime.current, sport).order('start_date DESC').includes(:venue) }
  scope :all_future,  ->              { where('start_date >= ?' , DateTime.current).order('start_date ASC').includes(:venue) }
  scope :all_past,    ->              { where('start_date < ?' , DateTime.current).order('start_date DESC').includes(:venue) }

  # Serialize any specialized fields
  serialize :specialized

  def home_players
    raise "No home team for game: #{id}" unless home_team
    players.where(team_id: home_team.id)
  end

  def away_players
    raise "No away team for game: #{id}" unless away_team
    players.where(team_id: away_team.id)
  end

  def start_date_s
    timezone = CHAMPTRACKER_CONFIG[:default_timezone]
    start_date ? start_date.in_time_zone(timezone).strftime('%a %b %e, %Y @%-l:%M%P') : '(none)'
  end

  def end_date_s
    timezone = CHAMPTRACKER_CONFIG[:default_timezone]
    end_date ? end_date.in_time_zone(timezone).strftime('%a %b %e, %Y @%-l:%M%P') : '(none)'
  end

  def win_or_lose(current_team, reversed = false)

    at_home = current_team.id == home_team_id

    return '-' if home_team_score.nil? or away_team_score.nil?

    if at_home ^ reversed
      if home_team_score > away_team_score
        'W'
      elsif home_team_score < away_team_score
        'L'
      else
        'D'
      end
    else
      if home_team_score > away_team_score
        'L'
      elsif home_team_score < away_team_score
        'W'
      else
        'D'
      end
    end
  end

  def reset_player_stats!
    self.specialized = {}
    home_player_ids = home_players.pluck(:id)
    away_player_ids = away_players.pluck(:id)
    player_results.each do |result|
      next unless result.specialized
      if home_player_ids.include?(result.player_id)
        result.specialized.each do |k,v|
          home_key = "home_#{k}".to_sym
          self.specialized[home_key] ||= 0
          self.specialized[home_key] += v if v.instance_of?(Fixnum)
        end
      elsif away_player_ids.include?(result.player_id)
        result.specialized.each do |k,v|
          away_key = "away_#{k}".to_sym
          self.specialized[away_key] ||= 0
          self.specialized[away_key] += v if v.instance_of?(Fixnum)
        end
      else
        logger.warn("PlayerResult id=#{result.id} is not in a home or away team!")
      end
    end
  end

end
