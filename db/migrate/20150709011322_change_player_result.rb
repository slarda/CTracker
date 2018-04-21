class ChangePlayerResult < ActiveRecord::Migration
  def up
    change_column :player_results, :goals, :integer, null: true
    change_column :player_results, :own_goals, :integer, null: true
    change_column :player_results, :subst_on, :integer, null: true
    change_column :player_results, :subst_off, :integer, null: true
    change_column :player_results, :minutes_played, :integer, null: true
  end

  def down
    change_column :player_results, :goals, :integer, default: 0, null: false
    change_column :player_results, :own_goals, :integer, default: 0, null: false
    change_column :player_results, :subst_on, :integer, default: 0, null: false
    change_column :player_results, :subst_off, :integer, default: 0, null: false
    change_column :player_results, :minutes_played, :integer, default: 0, null: false
  end

end
