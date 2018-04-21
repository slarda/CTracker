class CoachForPositions < ActiveRecord::Migration
  def up
    Position.where(position: 'Coach', sport: 'Soccer').first_or_create!
  end

  def down
    Position.where(position: 'Coach', sport: 'Soccer').destroy_all
  end
end
