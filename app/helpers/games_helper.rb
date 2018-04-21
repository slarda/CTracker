module GamesHelper

  def is_home_or_away(home_team,away_team)
    return '' unless @current_team and home_team and away_team
    @current_team.id == home_team.id ? 'home' : (@current_team.id == away_team.id ? 'away' : 'unknown')
  end
end