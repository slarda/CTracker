class ChangeAttributes < ActiveRecord::Migration
  def up
    change_column :games, :round, :string
    add_column :games, :round_str, :string
    add_column :player_results, :notes, :text
  end

  def down
    change_column :games, :round, :integer
    remove_column :games, :round_str
    remove_column :player_results, :notes
  end

end
