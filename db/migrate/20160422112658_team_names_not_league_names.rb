class TeamNamesNotLeagueNames < ActiveRecord::Migration
  def up
    Team.joins(:league).includes(:club).where('teams.name = leagues.name AND teams.club_id IS NOT NULL').find_in_batches do |batch|
      batch.each do |team|
        team.update_attribute(:name, team.club.name)
      end
    end
    Team.update_all(display_state: Team.display_states[:not_club_name])
  end

  def down
    Rails.logger.warn 'Cannot rollback data migration: TeamNamesNotLeagueNames'
  end
end
