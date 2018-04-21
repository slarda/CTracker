class AddLeagueCountToTeams < ActiveRecord::Migration
  def up
    add_column :teams, :league_count, :integer, default: 0, nullable: false

    # Merge any leagues with the same name
    duplicates = League.select('id,name,COUNT(id) AS cnt').group('name').select {|x| x['cnt'] > 1}
    duplicates.each do |duplicate|
      leagues = League.where(name: duplicate.name)
      first = leagues.first
      leagues[1..-1].each do |dup|
        dup.teams.each do |team|
          team.league = first
          team.save!
        end
        dup.destroy
      end
    end

    connection = ActiveRecord::Base.connection
    result = connection.execute('SELECT id, club_id, league_id, COUNT(id) AS team_count FROM teams GROUP BY club_id, league_id')
    result.each do |team_details|
      Team.find(team_details[0]).update_attribute(:league_count, team_details[3])
    end
  end

  def down
    remove_column :teams, :league_count
  end
end
