class AddSportToGames < ActiveRecord::Migration
  def up
    add_column :games, :sport, :string, default: 'soccer', nullable: false
    add_column :teams, :sport, :string, default: 'soccer', nullable: false
    add_column :clubs, :sport, :string, default: 'soccer', nullable: false

    Game.update_all(sport: 'soccer')
    Club.update_all(sport: 'soccer')
    Team.update_all(sport: 'soccer')
    PlayerResult.update_all(sport: 'soccer')
  end

  def down
    remove_column :games, :sport
    remove_column :teams, :sport
    remove_column :clubs, :sport
  end
end
