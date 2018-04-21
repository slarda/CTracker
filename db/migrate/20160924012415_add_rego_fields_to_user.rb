class AddRegoFieldsToUser < ActiveRecord::Migration
  def change
    add_column :users, :entered_club_name, :string
    add_column :users, :entered_team_name, :string
    add_column :users, :entered_league_name, :string
    add_column :users, :entered_website, :text
    add_column :users, :entered_additional_info, :text
  end
end
