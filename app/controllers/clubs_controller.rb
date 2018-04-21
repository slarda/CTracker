class ClubsController < ApplicationController

  respond_to :json

  def index
    association_id = params[:association_id].try(:to_i)

    if association_id
      @clubs = Association.find(association_id).clubs.all
    elsif params[:letter] and params[:letter].length == 1
      @clubs = Club.where("name LIKE '#{params[:letter]}%' AND sport=?", 'soccer')
    else
      raise ActionController::ParameterMissing.new('association_id, letter')
    end
    authorize! :read, Club if @clubs.empty?
    @clubs.each do |club|
      authorize! :read, club
    end
    render layout: false
  end

  def create
    @club = Club.new(club_params)
    authorize! :create, @club
    @club.save!
    render json: @club
  end

  def update
    @club = Club.find(params[:id].to_i)
    authorize! :update, @club
    @club.update_attributes(club_params)
    render json: @club
  end

  def destroy
    @club = Club.find(params[:id].to_i)
    authorize! :delete, @club
    @club.destroy!
    head :ok
  end

  def show
    @club = Club.find(params[:id].to_i)
    @filter_year = params[:year] if params[:year]
    authorize! :read, @club
  end

  def upload
    raise ActionController::BadRequest if params[:file].nil?

    puts "Filename: #{params[:file].original_filename}"
    puts "Content type: #{params[:file].content_type}"

    # TODO: Verify authorization

    @club = Club.find(params[:id])
    authorize! :update, @club

    @club.logo = params[:file]
    @club.save!

    render 'clubs/show'
  end

private

  def club_params
    params.permit(:name, :description, :location)
  end

end
