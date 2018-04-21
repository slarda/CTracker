class Position < ActiveRecord::Base
  has_many :player_positions, dependent: :destroy
  has_many :players,      through: :player_positions, source: :user
end