class AddSeasonToGame < ActiveRecord::Migration
  def up
    add_column :games, :season, :string
    Game.all.each do |game|
      game.update_attribute(:season, game.start_date.year) if game.start_date
    end
  end

  def down
    remove_column :games, :season
  end
end
