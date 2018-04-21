class AddTwitterWidgetToClub < ActiveRecord::Migration
  def change
    add_column :clubs, :twitter_widget, :string
  end
end
