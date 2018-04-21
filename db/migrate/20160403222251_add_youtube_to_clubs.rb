class AddYoutubeToClubs < ActiveRecord::Migration
  def change
    add_column :clubs, :youtube, :string
  end
end
