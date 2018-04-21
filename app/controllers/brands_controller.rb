class BrandsController < ApplicationController

  respond_to :json

  def index
    @brands = obtain_brands(params[:kind], params[:sport])
    authorize! :read, Brand if @brands.empty?
    @brands.each do |brand|
      authorize! :read, brand
    end

    render json: @brands
  end

  def create
    @brand = Brand.new(brand_params)
    authorize! :create, @brand
    @brand.save!
    render json: @brand
  end

  def update
    @brand = Brand.find(params[:id].to_i)
    authorize! :update, @brand
    @brand.update_attributes(brand_params)
    render json: @brand
  end

  def destroy
    @brand = Brand.find(params[:id].to_i)
    authorize! :delete, @brand
    @brand.destroy!
    head :ok
  end

  def show
    @brand = Brand.find(params[:id].to_i)
    authorize! :read, @brand
  end

private

  def obtain_brands(kind, sport)
    if kind.present?
      brands = Brand.joins(:equipments).includes(:equipments).where('equipment.equipment_type = ?',
                                     Equipment.equipment_types[kind.to_sym]).order(:name).uniq.all
    else
      brands = Brand.order(:name).all
    end
    filter_by_sport(brands, kind, sport)
  end

  def filter_by_sport(brands, equipment_type, sport)
    return brands unless equipment_type == 'boots'
    new_brands = []

    brands.each do |brand|
      brand.equipments.each do |equipment|
        # IC = Indoor Court
        if sport == 'futsal'
          if equipment.specialized and equipment.specialized[:surface] == 'IC'
            new_brands.push(brand)
            break
          end
        elsif sport == 'soccer'
          if equipment.specialized and equipment.specialized[:surface] != 'IC'
            new_brands.push(brand)
            break
          end
        else
          new_brands.push(brand)
        end
      end
    end
    new_brands
  end

  def brand_params
    params.permit(:name)
  end

end
