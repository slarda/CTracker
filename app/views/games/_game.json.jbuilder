json.(game, :id, :ref, :season, :start_date, :start_date_s, :end_date, :end_date_s, :round, :state, :association_id, :home_team_id, :away_team_id,
              :home_team_score, :away_team_score, :created_at, :updated_at)
json.venue do
  json.(game.venue, :address1, :address2, :address3, :suburb, :state, :zipcode, :full_address, :latitude, :longitude)
end if game.venue
home_team = game.home_team
away_team  = game.away_team
player_stat = game.player_results.select { |pr| pr.player_id == @user.id }.first if @user
json.player_stat do
  json.(player_stat, :id, :played_game, :goals, :own_goals, :minutes_played, :specialized)
  json.rating player_stat.rating if @own_stats
end if player_stat
json.home_team do
  json.(home_team, :id, :club_id, :association_id, :name, :description, :location, :augmented_league_name,
      :augmented_club_name, :league_count, :parent_id, :division_id, :created_at, :updated_at)
  json.club home_team.club
  json.assoc home_team.assoc
end
json.away_team do
  json.(away_team, :id, :club_id, :association_id, :name, :description, :location, :augmented_league_name,
      :augmented_club_name, :league_count, :parent_id, :division_id, :created_at, :updated_at)
  json.club away_team.club
  json.assoc away_team.assoc
end
json.home_or_away is_home_or_away(home_team,away_team)
