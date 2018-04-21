class AddNoStandingsToLeague < ActiveRecord::Migration
  def change
    add_column :leagues, :no_standings, :boolean, default: false, nullable: false
  end
end
