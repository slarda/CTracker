class User < ActiveRecord::Base

  # Constants
  enum gender: { unknown_gender: 0, male: 1, female: 2 }
  enum role: { unknown_role: 0, player: 1, parent_of: 2, coach: 3, fan: 4 }
  enum verified: { not_verified: 0, was_verified: 1 }

  # External (oauth) and password authentication
  authenticates_with_sorcery! do |config|
    config.authentications_class = Authentication
  end
  has_many :authentications, dependent: :destroy

  # Avatar support
  mount_uploader :avatar, AvatarUploader

  # Associations
  belongs_to :assoc,        class_name: 'Association', foreign_key: 'association_id'
  belongs_to :club,         inverse_of: 'participants', foreign_key: 'club_id'
  belongs_to :team,         inverse_of: 'players', foreign_key: 'team_id'
  has_one :player_profile,  dependent: :destroy
  has_many :sport_profiles, dependent: :destroy, autosave: false
  has_many :results,        class_name: 'PlayerResult', foreign_key: 'player_id', dependent: :destroy
  has_many :player_equipments
  has_many :previous_teams

  has_many :player_positions, dependent: :destroy
  has_many :positions,        through: :player_positions
  has_many :player_games,     through: :results, source: :game
  has_many :teams_past,       through: :previous_teams, class_name: 'Team', foreign_key: 'team_id', source: :team
  has_many :game_links
  has_many :awards
  has_many :media_sections

  # Virtual attribute for a single (exclusive) position
  attr_accessor :position_id

  # Scopes (shorthand to team)
  def next_game(sport)
    team.next_game(sport)
  end

  def future_games(sport)
    team.future_games(sport)
  end

  def past_games(sport)
    team.past_games(sport)
  end

  def all_past_games(sport)
    current_team_id = team.try(:id)
    sport_filter_sql = " AND sport=#{ActiveRecord::Base.sanitize(sport)}" unless sport == 'all'
    if current_team_id
      Game.find_by_sql(['SELECT * FROM (' \
                            '(SELECT DISTINCT games.* FROM previous_teams ' \
                              'INNER JOIN games ON previous_teams.user_id = ? AND ' \
                              '((games.home_team_id = previous_teams.team_id OR ' \
                               'games.away_team_id = previous_teams.team_id) ' \
                                "AND games.start_date <= NOW()#{sport_filter_sql})) " \
                          'UNION' \
                            '(SELECT games.* FROM games WHERE (games.home_team_id = ? OR games.away_team_id = ?) AND ' \
                              'games.start_date <= NOW()) ' \
                        ') t ' \
                        'ORDER BY start_date DESC, end_date DESC', id, current_team_id, current_team_id])
    else
      Game.find_by_sql(['SELECT DISTINCT games.* FROM previous_teams ' \
                          'INNER JOIN games ON previous_teams.user_id = ? AND ' \
                            '((games.home_team_id = previous_teams.team_id OR ' \
                            'games.away_team_id = previous_teams.team_id)' \
                            ") AND games.start_date <= NOW()#{sport_filter_sql}) " \
                        'ORDER BY games.start_date DESC, games.end_date DESC', id])
    end
  end

  def all_past_games_eager(sport)
    game_ids = all_past_games(sport).map(&:id)
    Game.includes([{ home_team: [:club, :league, :assoc]}, { away_team: [:club, :league, :assoc] }, :venue, :player_results]).where(id: game_ids)
  end

  def last_game(sport='soccer')
    team.last_game(sport)
  end

  # Nested attributes
  accepts_nested_attributes_for :authentications
  accepts_nested_attributes_for :player_profile
  accepts_nested_attributes_for :player_equipments
  accepts_nested_attributes_for :awards
  accepts_nested_attributes_for :media_sections

  # Validations
  validates_presence_of :first_name, :last_name, :email, :gender
  validates_presence_of :password, on: :create, unless: :bulk_loaded?
  validates_presence_of :role, message: ": 'About me' can't be blank"
  validates_acceptance_of :agree_terms, message: 'must be accepted', accept: true, unless: :bulk_loaded?

  # Callbacks
  before_create :link_associations
  after_save :check_roles
  after_create :email_new_member

  # Accessors
  attr_accessor :disable_notification

  def past_team_games
    # TODO: deprecated?

    # Find all games for the team in any previous teams the user has joined, in instances where no other game data is
    # available
    Game.find_by_sql(['SELECT * FROM previous_teams ' \
                      'INNER JOIN games ON previous_teams.user_id = ? AND ' \
                      'previous_teams.num_results = 0 AND ' \
                      '(games.home_team_id = previous_teams.team_id OR games.away_team_id = previous_teams.team_id) ' \
                      'AND games.start_date >= previous_teams.starts_at AND ' \
                      'games.end_date <= previous_teams.ends_at ' \
                      'ORDER BY games.start_date DESC, games.end_date DESC', id])
  end

  def dob_s
    dob ? dob.to_formatted_s(:long) : ''
  end

  def initials
    "#{first_name[0].try(:upcase)}#{last_name[0].try(:upcase)}"
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def update_team(new_team)
    return if new_team.nil? or (team and new_team.id == team.id)

    unless team
      self.team = new_team
      save!
      return
    end

    # Determine the last date, based on last 'previous team', or earliest game from player results, or earliest game
    # from team
    if team.year < new_team.year
      teams_past << team
      self.team = new_team
      save!
    else
      teams_past << new_team
    end

    # last_date = previous_teams.order('ends_at DESC').first.try(:end_date)
    # last_date ||= player_games.order('start_date ASC').first.try(:start_date)
    # last_date ||= self.team.past_games.last.try(:start_date) if self.team

    # Create a PreviousTeam that summarises the available player results
    # if self.team and last_date
    #   game_count = player_games.where('start_date >= ?', last_date).count
    #   previous_teams.build(starts_at: last_date, ends_at: DateTime.current, num_results: game_count, team: self.team)
    #   self.team_changed_at = DateTime.current
    # end

    # update the team
    # self.team = team
  end

  def active_sport_profile
    sport_profiles.where(sport: active_sport).first
  end

private

  def link_associations
    self.club = team.club if team
    self.assoc = club.assoc if club
  end

  def check_roles
    asp = active_sport_profile
    return unless asp
    if role == 'coach'
      unless asp.position == 'Assistant Coach'
        asp.position = 'Coach'
        asp.player_no = 'C'
        asp.save!
      end

    elsif role == 'player'
      if asp.position == 'Coach' or asp.position == 'Assistant Coach'
        asp.position = 'Forward'
        asp.player_no = nil
        asp.save!
      end
    end
  end

  def email_new_member
    UserMailer.to_new_member(self).deliver_later unless @disable_notification
  end

  def bulk_loaded?
    self.activation_state.eql?('bulk')
  end

end
