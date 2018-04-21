json.(game_players, :id, :ref, :season, :start_date, :start_date_s, :end_date, :end_date_s, :round, :state, :association_id, :home_team_id, :away_team_id,
              :home_team_score, :away_team_score, :created_at, :updated_at)
json.venue do
  json.(game_players.venue, :address1, :address2, :address3, :suburb, :state, :zipcode, :full_address, :latitude, :longitude)
end if game_players.venue
home_team = game_players.home_team
away_team  = game_players.away_team
json.specialized game_players.specialized
json.home_team do
  json.(home_team, :id, :club_id, :association_id, :name, :description, :location, :augmented_league_name,
      :augmented_club_name, :league_count, :parent_id, :division_id, :created_at, :updated_at)
  json.club home_team.club
  json.assoc home_team.assoc
  json.players do
    json.array! game_players.home_players, :id, :initials, :full_name
  end
end
json.away_team do
  json.(away_team, :id, :club_id, :association_id, :name, :description, :location, :augmented_league_name,
      :augmented_club_name, :league_count, :parent_id, :division_id, :created_at, :updated_at)
  json.club away_team.club
  json.assoc away_team.assoc
  json.players do
    json.array! game_players.away_players, :id, :initials, :full_name
  end
end
json.home_or_away (@current_team.id == home_team.id ? 'home' : (@current_team.id == away_team.id ? 'away' : 'unknown'))
