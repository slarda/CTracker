class AddPassportsToUsers < ActiveRecord::Migration
  def change
    add_column :player_profiles, :passport1, :string
    add_column :player_profiles, :passport2, :string
  end
end
