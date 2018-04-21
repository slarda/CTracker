class CreateLeagues < ActiveRecord::Migration
  def up
    #rails g migration CreateLeagues name:string association:references
    create_table :leagues do |t|
      t.string :name
      t.references :association, index: true, foreign_key: true
      t.timestamps null: false
    end

    add_reference :teams, :league

    # Now go through each team and add a league if required
    add_leagues_to_teams
  end

  def down
    remove_reference :teams, :league
    drop_table :leagues
  end

  def add_leagues_to_teams
    Team.all.each do |team|
      league = League.where(name: team.name).first_or_create!(assoc: team.assoc)
      team.league = league
      team.save!
    end
  end
end
