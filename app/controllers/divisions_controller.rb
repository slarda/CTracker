class DivisionsController < ApplicationController

  # TODO: Authorizations

  respond_to :json

  def index
    association_id = params[:association_id].to_i
    @divisions = Association.find(association_id).divisions.all
    render json: @divisions
  end

  def create
    division = Division.new(division_params)
    division.save!
    render json: division
  end

  def update
    division = Division.find(params[:id].to_i)
    division.update_attributes(division_params)
    render json: division
  end

  def destroy
    division = Division.find(params[:id].to_i)
    division.destroy!
    head :ok
  end

  def show
    @division = Division.find(params[:id].to_i)
  end

private

  def division_params
    params.permit(:name, :description)
  end

end
