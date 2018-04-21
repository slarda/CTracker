class CreatePreviousTeams < ActiveRecord::Migration
  def change
    create_table :previous_teams do |t|
      t.references :user
      t.references :team
      t.timestamps      null: true
    end
  end
end
