class AddRatingToPlayerResult < ActiveRecord::Migration
  def change
    add_column :player_results, :rating, :integer
  end
end
