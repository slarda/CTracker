class AddFormationToPlayerResult < ActiveRecord::Migration
  def change
    add_column :player_results, :formation, :string
  end
end
