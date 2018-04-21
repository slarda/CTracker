class UsersController < ApplicationController

  # Modules
  include Users::Statistics

  respond_to :json

  # Users can create their own accounts
  skip_before_action :require_login, only: [:create, :show, :season_stats, :playing_career]

  def index
    raise CanCan::AccessDenied unless current_user.super_admin
    @users = User.all
    @users.each do |user|
      authorize! :read, user
    end
  end

  def create
    @user = User.new(user_params)
    authorize! :create, @user

    @user.player_profile ||= PlayerProfile.new
    sport_profile = @user.sport_profiles.where(sport: @user.active_sport).first_or_initialize

    sport_profile.update_attributes!(player_no: 'C', position: 'Coach') if @user.positions.try(:first) and
        @user.positions.first.position.eql?('Coach')
    sport_profile.update_attributes!(player_no: 'AC', position: 'Assistant Coach') if @user.positions.try(:first) and
        @user.positions.first.position.eql?('Assistant Coach')

    # Update the positions - should only one submitted
    if params[:position_id]
      @user.positions = Position.where(id: params[:position_id].to_i)
      sport_profile.update_attribute(:position, @user.positions.first.position)
    end
    @user.save!

    # TODO: If we just created a user, login as that user (assuming we were anonymous to start with)
    # TODO: What about admin users?
    auto_login(@user)

    render json: @user
  end

  def update
    @user = User.find(params[:id].to_i)
    authorize! :update, @user

    @user.update_attributes!(user_params)
    sport_profile = @user.sport_profiles.where(sport: @user.active_sport).first_or_initialize
    spp = sport_profile_params
    sport_profile.update_attributes!(sport_profile_params) if sport_profile and spp

    # Update the positions - should only be one submitted
    if params[:position_id]
      @user.positions = Position.where(id: params[:position_id].to_i)
      sport_profile.update_attribute(:position, @user.positions.first.position) if @user.positions.first
    end
    @user.player_profile ||= PlayerProfile.new

    sport_profile.update_attributes!(player_no: 'C', position: 'Coach') if @user.positions.try(:first) and
        @user.positions.first.position.eql?('Coach')
    sport_profile.update_attributes!(player_no: 'AC', position: 'Assistant Coach') if @user.positions.try(:first) and
        @user.positions.first.position.eql?('Assistant Coach')

    @user.save!

    render :show
  end

  def destroy
    @user = User.find(params[:id].to_i)
    authorize! :delete, @user
    @user.destroy!
    head :ok
  end

  def show
    @current_user = current_user
    @user = User.includes(:sport_profiles, :awards, player_equipments: { equipment: :equipment_photos }).
            find(params[:id].to_i)
    authorize! :read, @user
  end

  def impersonate
    authorize! :impersonate, current_user
    @user = User.find(params[:id])
    impersonate_user(@user)
    redirect_to root_path
  end

  def unimpersonate
    @true_user = true_user
    authorize! :unimpersonate, @true_user
    stop_impersonating_user
    redirect_to admin_users_path
  end

  def current
    @user = current_user
    authorize! :read, @user
    render :show
  end

  def update_club
    @club = Club.find(params[:club_id].to_i)
    authorize! :update, current_user
    current_user.update_attributes!(club: @club, assoc: @club.assoc)
    render json: @club
  end

  def update_team
    @team = Team.find(params[:team_id].to_i)
    authorize! :update, current_user
    current_user.update_team(@team)
    render json: @team
  end

  def upload

    # Save the user avatar into the session, attached to this communications
    unless params[:file].nil?
      puts "Filename: #{params[:file].original_filename}"
      puts "Content type: #{params[:file].content_type}"

      if params[:user_id]
        user = User.find(params[:user_id].to_i)
        authorize! :update, user
        user.avatar = params[:file]
        user.save!
      else
        authorize! :update, current_user
        current_user.avatar = params[:file]
        current_user.save!
      end

    end

    render json: params[:user_id] ? user : current_user, include:
                          [:player_profile,
                           { positions: { only: :id } },
                           { club: { only: [:id, :name] } },
                           :team,
                           :player_equipments,
                           :avatar
                          ]
  end

  def season_stats
    # Note: side-effect is @user is set
    map = get_season_stats(params[:id].to_i, params[:sport] || 'soccer', params[:all_games] == '1')
    authorize! :read, @user
    render json: map
  end

  def playing_career
    # Note: side-effect is @user is set
    map = get_player_stats(params[:id].to_i, params[:sport] || 'soccer', params[:all_games] == '1')
    authorize! :read, @user
    render json: map
  end

  def prior_games
    authorize! :read, Game
    player_id = params[:id]

    # Load games and player results with optimal performance (joins, includes)
    @games = Game.joins(:player_results).includes(
            [
              { :home_team => [:club, :assoc] },
              { :away_team => [:club, :assoc] },
              { :player_results => { :team => [:club, :assoc] } },
              :venue
            ]).where('player_results.player_id = ?', player_id.to_i).
             order('games.start_date DESC, games.end_date DESC') if player_id

    @games ||= []
    @current_team = current_user.team
  end

  def team_games
    # TODO: deprecated?
    # Find all games for the team in any previous teams the user has joined, in instances where no other game data is available
    @games = User.find(params[:id].to_i).past_team_games
    @current_team = current_user.team
  end

private

  def sport_profile_params
    params.permit(active_sport_profile: [:id, :position, :sport, :player_no])[:active_sport_profile]
  end

  def user_params
    permitted = [:email, :password, :password_confirmation, :first_name, :last_name, :middle_name, :nickname, :role,
                 :dob, :gender, :agree_terms, :nationality, :position_id,
                 :club_name, :team_name, :league_name, :website_link, :additional_info,
                 # team_id from user's profile
                 team: [:id],
                 player_profile: [:id, :height_cm, :height_ft, :height_in, :weight_kg, :biography, :player_no,
                                  :handedness, :highlights_video, :passport1, :passport2],
                 awards: [:id, :year, :award, :team_id],
                 media_sections: [:id, :title, :image_url, :external_link, :description],
                 player_equipments: [:id, :brand, :model, :equipment_type]
                ]


    # Deal with deep munge security issue: https://github.com/rails/rails/issues/13766
    remap_nested_attributes(params.permit(*permitted))
  end

  def remap_nested_attributes(hash)
    player_profile = hash[:player_profile]
    player_equipments = hash[:player_equipments]
    awards = hash[:awards]
    media_sections = hash[:media_sections]
    team = hash[:team]

    # Remap user-entered data
    hash.merge!(entered_club_name: hash.delete(:club_name)) if hash[:club_name]
    hash.merge!(entered_team_name: hash.delete(:team_name)) if hash[:team_name]
    hash.merge!(entered_league_name: hash.delete(:league_name)) if hash[:league_name]
    hash.merge!(entered_website: hash.delete(:website_link)) if hash[:website_link]
    hash.merge!(entered_additional_info: hash.delete(:additional_info)) if hash[:additional_info]

    return hash unless player_profile or team or player_equipments
    hash = hash.reject{ |k,v| k == 'player_profile' or k == 'team' or k == 'player_equipments' or k == 'active_sport_profile' }
    hash.merge!(player_profile_attributes: player_profile) if player_profile
    hash.merge!(player_equipments_attributes: player_equipments) if player_equipments
    hash.merge!(team_id: team['id']) if team
    hash.merge!(awards_attributes: awards) if awards
    hash.delete(:awards)
    hash.merge!(media_sections_attributes: media_sections) if media_sections
    hash.delete(:media_sections)
    hash
  end
end
