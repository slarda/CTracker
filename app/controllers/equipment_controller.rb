require 'tmpdir'

class CsvLoader
  include Gear::Csv
end

class EquipmentController < ApplicationController

  respond_to :json

  include Gear::Csv

  def index
    brand_id = params[:brand_id]
    model = params[:model]
    if params[:equipment_type]
      equipment_type = Equipment.equipment_types[params[:equipment_type]]
      raise ActionController::BadRequest unless equipment_type
    end
    sport = params[:sport]
    raise ActionController::ParameterMissing.new('sport') unless sport

    @equipment = Equipment.where(equipment_type: equipment_type).order(model: :asc) if equipment_type
    @equipment = filter_by_brand(@equipment, brand_id) if brand_id
    @equipment = filter_by_model(@equipment, model) if model
    raise ActionController::ParameterMissing.new('equipment_type, brand, model') unless @equipment

    @equipment = filter_by_sport(@equipment, equipment_type, sport)

    authorize! :read, Equipment if @equipment.empty?
    @equipment.each do |equipment|
      authorize! :read, equipment
    end

    render json: @equipment, include: [:brand, :equipment_photos]
  end

  def create
    @equipment = Equipment.new(equipments_params)
    authorize! :create, @equipment
    @equipment.save!
    render json: @equipment
  end

  def update
    @equipment = Equipment.find(params[:id].to_i)
    authorize! :update, @equipment
    @equipment.update_attributes(equipments_params)
    render json: @equipment
  end

  def destroy
    @equipment = Equipment.find(params[:id].to_i)
    authorize! :delete, @equipment
    @equipment.destroy!
    head :ok
  end

  def show
    @equipment = Equipment.find(params[:id].to_i)
    authorize! :read, @equipment
  end

  def csv_upload
    authorize! :update, Equipment

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
        count = CsvLoader.load_gear tempfile

      ensure
        # Unlink the file
        File.unlink tempfile
      end

      flash[:notice] = "Upload successful - #{params[:file].original_filename} with #{count} records."
    end
  end


private

  def filter_by_brand(equipment, brand_id)
    (equipment || Equipment).where(brand_id: brand_id.to_i).order(model: :asc)
  end

  def filter_by_model(equipment, model)
    (equipment || Equipment).where(model: model).order(model: :asc)
  end

  def filter_by_sport(equipment, equipment_type, sport)
    return equipment unless equipment_type == Equipment.equipment_types[:boots]
    new_equipment = []
    equipment.each do |eq|
      # IC = Indoor Court
      if sport == 'futsal'
        new_equipment.push(eq) if eq.specialized and eq.specialized[:surface] == 'IC'
      elsif sport == 'soccer'
        new_equipment.push(eq) if eq.specialized and eq.specialized[:surface] != 'IC'
      else
        new_equipment.push(eq)
      end
    end
    new_equipment
  end

  def equipments_params
    params.permit(:brand, :equipment_type, :model, :specialized)
  end

end
