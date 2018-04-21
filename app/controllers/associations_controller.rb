class AssociationsController < ApplicationController

  respond_to :json

  def index
    @associations = Association.all
    authorize! :read, Association if @associations.empty?
    @associations.each do |association|
      authorize! :read, association
    end
    render json: @associations
  end

  def create
    @association = Association.new(association_params)
    authorize! :create, @association
    @association.save!
    render json: @association
  end

  def update
    @association = Association.find(params[:id].to_i)
    authorize! :update, @association
    @association.update_attributes(association_params)
    render json: @association
  end

  def destroy
    @association = Association.find(params[:id].to_i)
    authorize! :delete, @association
    @association.destroy!
    head :ok
  end

  def show
    @association = Association.find(params[:id].to_i)
    authorize! :read, @association
  end

  def upload
    raise ActionController::BadRequest if params[:file].nil?

    puts "Filename: #{params[:file].original_filename}"
    puts "Content type: #{params[:file].content_type}"

    # TODO: Verify authorization

    @association = Association.find(params[:id])
    authorize! :update, @association

    @association.logo = params[:file]
    @association.save!

    render 'associations/show'
  end

private

  def association_params
    params.permit(:name, :description, :url, :location)
  end

end
