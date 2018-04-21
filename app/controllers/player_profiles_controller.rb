class PlayerProfilesController < ApplicationController

  # TODO: Authorizations

  respond_to :json

  def index
    profiles = PlayerProfile.all
    render json: profiles
  end

  def create
    profile = PlayerProfile.new(profile_params)
    profile.save!
    render json: profile
  end

  def update
    profile = PlayerProfile.find(params[:id].to_i)
    profile.update_attributes(profile_params)
    render json: profile
  end

  def destroy
    profile = PlayerProfile.find(params[:id].to_i)
    profile.destroy!
    head :ok
  end

  def show
    profile = PlayerProfile.find(params[:id].to_i)
    render json: profile
  end

  private

  def profile_params
    params.permit(:xxx)
  end

end
