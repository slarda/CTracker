class PositionsController < ApplicationController

  respond_to :json

  def index
    raise ActionController::ParameterMissing.new('sport') unless params[:sport]
    @positions = Position.where(sport: params[:sport])
      @positions =  if current_user.role == 'coach'
                      @positions.where("roles LIKE '%coach%'")
                    else
                      @positions.where("roles IS NULL OR roles NOT LIKE '%coach%'")
                    end

    authorize! :read, Position if @positions.empty?
    @positions.each do |position|
      authorize! :read, position
    end

    # Handle subsets of positions for certain roles
    @positions = @positions.to_a
    if current_user.role == 'coach'
      @positions.delete_if { |position| not is_coaching_role?(position.roles) }
    else
      @positions.delete_if { |position| is_coaching_role?(position.roles) }
    end

    render json: @positions
  end

  # def create
  #   @association = Association.new(association_params)
  #   @association.save!
  #   render json: @association
  # end
  #
  # def update
  #   @association = Association.find(params[:id].to_i)
  #   @association.update_attributes(association_params)
  #   render json: @association
  # end
  #
  # def destroy
  #   @association = Association.find(params[:id].to_i)
  #   @association.destroy!
  #   head :ok
  # end
  #
  # def show
  #   @association = Association.find(params[:id].to_i)
  # end

  private

    def position_params
      #params.permit(:)
    end

    def is_coaching_role?(roles)
      return false if roles.blank?
      roles.split(',').include?('coach')
    end

end
