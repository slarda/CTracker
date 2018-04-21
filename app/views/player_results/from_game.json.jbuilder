json.(@result, :id, :played_game, :sport, :formation, :goals, :own_goals, :subst_on, :subst_off, :id, :home_or_away,
          :minutes_played, :specialized, :player_id, :game_id, :team_id, :created_at, :updated_at,
          :game_links) if @result
json.show_rating @result.show_rating if @result
if @show_rating_and_notes
  json.rating @result.rating
  json.notes @result.notes
end