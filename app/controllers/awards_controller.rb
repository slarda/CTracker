class AwardsController < ApplicationController

  respond_to :json

  def index
    @awards = Award.all
    authorize! :read, Award if @awards.empty?
    @awards.each do |award|
      authorize! :read, award
    end
    render json: @awards
  end

  def create
    @award = Award.new(award_params)
    authorize! :create, @award
    @award.save!
    render json: @award
  end

  def update
    @award = Award.find(params[:id].to_i)
    authorize! :update, @award
    @award.update_attributes(award_params)
    render json: @award
  end

  def destroy
    @award = Award.find(params[:id].to_i)
    authorize! :destroy, @award
    @award.destroy!
    head :ok
  end

  def show
    @award = Award.includes([{home_team: {players: :player_profile}}, {away_team: {players: :player_profile}}]).
        find(params[:id].to_i)
    authorize! :read, @award
    @current_team = current_user.team
  end

private

  def award_params
    params.permit(:year, :award, :team_id, :user_id)
  end

end
