class PlayerResult < ActiveRecord::Base

  # Modules
  include PlayerResults::Callbacks

  # Associations
  belongs_to :player, class_name: 'User', foreign_key: 'player_id'
  belongs_to :game
  belongs_to :team
  has_many :game_links, as: :linked_to, autosave: true

  # Validations
  validates_inclusion_of :played_game, in: [true, false]
  validates_presence_of :sport

  # Enumerations
  enum home_or_away: {unknown: 0, home_game: 1, away_game: 2}

  # Serialize any specialized fields - prev_specialized required as 'specialized_was' not implemented in Rails 4.x
  serialize :specialized
  attr_accessor :prev_specialized

  # Accessors - special temp fields
  attr_accessor :show_rating

  # Callbacks
  after_save :increment_game
  before_update :decrement_game
  before_destroy :unlink_game
  after_find do |pr|
    dup_specialized(pr)
  end

end
