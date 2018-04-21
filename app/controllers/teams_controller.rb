require 'tmpdir'

class CsvLoader
  include Games::Csv
  include Clubs::Logos
  include ContactDetails::Csv
end

class TeamsController < ApplicationController

  respond_to :json

  before_action :set_team, only: [:update, :destroy, :last_results, :previous_meetings]
  skip_before_action :require_login, only: [:show]

  def index
    club_id = params[:club_id].try(:to_i)
    division_id = params[:division_id].to_i
    @teams = club_id ? Club.find(club_id).teams.all : Division.find(division_id).teams.all
    authorize! :read, Team if @teams.empty?
    @teams.each do |team|
      authorize! :read, team
    end
    render json: @teams
  end

  def create
    @team = Team.new(team_params)
    authorize! :create, @team
    @team.save!
    render json: @team
  end

  def update
    authorize! :update, @team
    @team.update_attributes(team_params)
    render json: @team
  end

  def destroy
    authorize! :delete, @team
    @team.destroy!
    head :ok
  end

  def show
    @team = Team.includes(:club, :league, :assoc, :players, :player_results).find(params[:id].to_i)
    authorize! :read, @team
    @with_games = params[:with_games].eql?('1')
    @future_only = params[:future_only].eql?('1')
    @sport = params[:sport] || 'all'
    @user = User.find(params[:user_id].to_i) if params[:user_id]
    @own_stats = @user == current_user
    authorize! :read, @user if @user
  end

  # def last_results
  #   raise ActionController::ParameterMissing.new('other_team') unless params[:other_team]
  #   other_team = Team.find(params[:other_team].to_i)
  #   @results = Game.where('home_team_id IN (?,?) AND away_team_id IN (?,?) AND start_date < ?',
  #                         @team.id, other_team.id, @team.id, other_team.id, DateTime.current).order('start_date DESC')
  #   @current_team = current_user.team
  # end

  def previous_meetings
    @other_team = Team.find(params[:other_team].to_i)
    authorize! :read, Team
    @team1 = Game.includes(:home_team, :away_team).where(
             '(home_team_id IN (?) OR away_team_id IN (?)) AND start_date < ?', @team.id, @team.id, DateTime.current).
             order('start_date DESC').limit(5)
    @team2 = Game.includes(:home_team, :away_team).where(
             '(home_team_id IN (?) OR away_team_id IN (?)) AND start_date < ?', @other_team.id, @other_team.id,
             DateTime.current).order('start_date DESC').limit(5)
    @current_team = current_user.team
  end

  # def previous_games
  #   team_ids = params[:team_ids].split(',')
  #   raise ActionController::ParameterMissing, 'team_ids' unless team_ids.present?
  #   @teams = Team.find(team_ids)
  #   @teams.each do |team|
  #     authorize! :read, team
  #   end
  #   @games = Game.includes(:home_team, :away_team).where('(home_team_id IN (?) OR away_team_id IN (?))', team_ids,
  #                                                        team_ids)
  #   render json: @games
  # end

  def csv_upload
    authorize! :update, Game
    authorize! :update, PlayerResult

    # TODO: Admin only function
    if params[:file]
      puts "Filename: #{params[:file].original_filename}"
      puts "Content type: #{params[:file].content_type}"

      # Check its a CSV file
      unless params[:file].content_type.eql?('text/csv') or not params[:file].original_filename.ends_with?('.csv')
        flash[:notice] = 'Upload CSV files only!'
        return
      end

      # Save the file with the original filename
      tempdir = Dir.tmpdir
      tempfile = "#{tempdir}/#{params[:file].original_filename}"
      file = File.new(tempfile, 'w')
      file.write params[:file].read
      file.close
      begin
        # Do the import
        CsvLoader.setup_uniqueness_check
        if params[:file].original_filename.include?('Player')
          count, new_records = CsvLoader.load_player_stats tempfile
          skipped = 0
        else
          count, skipped, new_records = CsvLoader.load_game_stats tempfile
        end

      # Unlink the file
      ensure
        File.unlink tempfile
      end

      flash[:notice] = "Upload successful - #{params[:file].original_filename} with #{count} records, #{skipped}" \
        " skipped, #{new_records} new records."
    end
  end

private

  def set_team
    @team = Team.find(params[:id].to_i)
  end

  def team_params
    params.permit(:name, :description, :location)
  end

end
