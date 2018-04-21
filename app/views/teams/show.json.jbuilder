json.extract! @team, :id, :name, :description, :location, :league_count, :augmented_league_name,
                     :augmented_club_name, :club_id
json.players @team.players, :id, :first_name, :last_name, :avatar_url
json.club @team.club
json.league @team.league

if @with_games
  json.future_games @team.future_games(@sport), partial: 'games/game', as: :game
  unless @future_only
    # TODO: switch to .all_past_games_eager (currently broken)
    json.past_games (@user ? @user.all_past_games(@sport) : @team.past_games(@sport)), partial: 'games/game', as: :game
  end
end
