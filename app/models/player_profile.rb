class PlayerProfile < ActiveRecord::Base

  belongs_to :user, autosave: false

  enum handedness: {left_foot: 1, right_foot: 2, left_hand: 3, right_hand: 4}

end
