class LeaguesController < ApplicationController

  respond_to :json

  include Leagues::Standings

  skip_before_action :require_login, only: [:standings]

  def standings
    @league = League.includes(teams: [:club, :home_games, :away_games]).find(params[:id])
    authorize! :read, @league
    teams, clubs, games = obtain_teams_clubs_games(@league, params[:season])
    @results = { league: @league.name, listings: summarise_league_standings(teams, clubs, games),
                 no_standings: @league.no_standings }
    render json: @results
  end

private

  def league_params
    params.permit(:id)
  end

end
