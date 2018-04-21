class PlayerEquipmentController < ApplicationController

  respond_to :json

  def index
    @equipment = PlayerEquipment.all
    authorize! :read, Equipment if @equipment.empty?
    @equipment.each do |equipment|
      authorize! :read, equipment
    end

    render json: @equipment
  end

  def create
    @equipment = PlayerEquipment.new(player_equipment_params)
    authorize! :create, @equipment
    @equipment.save!
    # Reload to get the equipment association
    @equipment = PlayerEquipment.find(@equipment.id)
    render json: @equipment, includes: [{player_equipments: {equipment: :equipment_photos}}]
  end

  def update
    @equipment = PlayerEquipment.find(params[:id].to_i)
    authorize! :update, @equipment
    @equipment.update_attributes(player_equipment_params)
    # Reload to get the equipment association
    @equipment = PlayerEquipment.find(@equipment.id)
    render json: @equipment, includes: [{player_equipments: {equipment: :equipment_photos}}]
  end

  def destroy
    @equipment = PlayerEquipment.find(params[:id].to_i)
    authorize! :delete, @equipment
    @equipment.destroy!
    head :ok
  end

  def show
    @equipment = PlayerEquipment.find(params[:id].to_i)
    authorize! :read, @equipment
  end

private

  def player_equipment_params
    params.permit(:equipment_type, :model, :specialized, :colour, :brand, :user_id, :equipment_id)
  end

end
