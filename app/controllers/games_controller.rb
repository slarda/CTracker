class GamesController < ApplicationController

  respond_to :json

  def index
    @games = Game.all
    authorize! :read, Game if @games.empty?
    @games.each do |game|
      authorize! :read, game
    end
    render json: @games
  end

  def create
    @game = Game.new(game_params)
    authorize! :create, @game
    @game.save!
    render json: @game
  end

  def update
    @game = Game.find(params[:id].to_i)
    authorize! :update, @game
    @game.update_attributes(game_params)
    render json: @game
  end

  def destroy
    @game = Game.find(params[:id].to_i)
    authorize! :destroy, @game
    @game.destroy!
    head :ok
  end

  def show
    @game = Game.includes([{home_team: {players: :player_profile}}, {away_team: {players: :player_profile}}]).
        find(params[:id].to_i)
    authorize! :read, @game
    @current_team = current_user.team
  end

  def weather_forecast
    game = Game.find(params[:id].to_i)
    authorize! :read, game
    weather = Weather.new
    begin
      @forecast = weather.forecast('Melbourne') #, 'Victoria', 'Australia')
      @for_game = weather.for_game_day(@forecast, game.start_date)
      @for_game[:date_s] = @for_game[:date].to_formatted_s(:short) if @for_game[:date]
      render json: @for_game
    rescue SocketError
      Rails.logger.warn "No weather available"
      render json: {}
    end
  end

private

  def game_params
    params.permit(:start_date, :end_date)
  end

end
