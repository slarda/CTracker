class AddHighlightsVideoToPlayerProfiles < ActiveRecord::Migration
  def change
    add_column :player_profiles, :highlights_video, :string
  end
end
