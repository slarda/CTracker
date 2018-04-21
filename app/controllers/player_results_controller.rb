class PlayerResultsController < ApplicationController

  respond_to :json

  skip_before_action :require_login, only: [:from_game, :from_games]

  def index
    @results = PlayerResult.where(game_id: params[:game_id].to_i).includes([{ player: :sport_profiles }, :game_links]).
        order('sport_profiles.player_no DESC')
    authorize! :read, PlayerResult if @results.empty?
    @results.each do |result|
      authorize! :read, result
    end
    @natural_ordering = @results.all.to_a.sort { |x,y| sort_order(x,y) }
    only_attributes = [:id, :played_game, :sport, :formation, :goals, :own_goals, :subst_on, :subst_off, :home_or_away, :minutes_played,
                       :specialized, :player_id, :game_id, :team_id, :created_at, :updated_at]
    only_attributes.push(:notes, :rating) if @results.first and @results.first.player_id == current_user.try(:id)
    attributes = { include: [:game_links,
                             { player: {only: [:id, :first_name, :last_name], include: :active_sport_profile } }],
                   only: only_attributes }
    render attributes.merge(json: @natural_ordering)
  end

  def create
    @result = PlayerResult.new(player_result_params)
    @result.player = current_user
    @result.team = current_user.team unless params[:team_id]
    handle_game_links(@result, params)
    if params[:team_id]
      fail ActionController::BadRequest, 'Invalid team ID' unless
          current_user.teams_past.pluck(:id).include?(params[:team_id]) or current_user.team_id == params[:team_id].to_i
      @result.team = Team.find(params[:team_id])
    end
    @result.played_game = params[:played_game].eql?('true')
    authorize! :create, @result

    fail ActionController::BadRequest, 'Your reputation must be higher' if
        (params[:home_score].present? or params[:away_score].present?) and current_user.reputation_score < 100

    if params[:specialized]
      @result.specialized = { penalty_saves: params[:specialized][:penalty_saves].to_i,
                              assists: params[:specialized][:assists].to_i,
                              yellow_cards: params[:specialized][:yellow_cards].to_i,
                              red_cards: params[:specialized][:red_cards].to_i }
    else
      @result.specialized = { penalty_saves: 0, assists: 0,
                              yellow_cards: 0, red_cards: 0 }
    end

    # Determine if home or away game
    update_home_or_away_games
    update_game_scores

    @result.save!
    @result.show_rating = true
    @show_rating_and_notes = true
    render :from_game
  end

  def update
    @result = PlayerResult.find(params[:id].to_i)
    authorize! :update, @result
    handle_game_links(@result, params)
    @result.specialized = { penalty_saves: params[:specialized][:penalty_saves].to_i,
                            assists: params[:specialized][:assists].to_i,
                            yellow_cards: params[:specialized][:yellow_cards].to_i,
                            red_cards: params[:specialized][:red_cards].to_i }

    # We do not use player_result_params so add any attributes specifically here
    @result.played_game = params[:played_game].eql?('true')
    @result.goals = params[:goals].to_i
    @result.rating = params[:rating].to_i if params[:rating]
    @result.minutes_played = params[:minutes_played].to_i
    @result.sport = params[:sport]
    @result.notes = params[:notes]
    @result.formation = params[:formation]

    fail ActionController::BadRequest, 'Your reputation must be higher' if
        (params[:home_score].present? or params[:away_score].present?) and current_user.reputation_score < 100

    # Determine if home or away game
    update_home_or_away_games
    update_game_scores

    @result.save!
    @result.show_rating = true
    @show_rating_and_notes = true
    render :from_game
  end

  def destroy
    @result = PlayerResult.find(params[:id].to_i)
    authorize! :delete, @result
    @result.destroy!
    head :ok
  end

  def show
    @result = PlayerResult.find(params[:id].to_i)
    authorize! :read, @result
  end

  def from_game
    @game = Game.find(params[:game_id].to_i)
    authorize! :read, @game
    @result = @game.player_results.includes(:game_links).where(player_id: params[:player_id].to_i).first

    if @result and current_user and @result.player_id == current_user.id
      @result.show_rating = true
      @show_rating_and_notes = true
    end
  end

  def from_games
    games = Game.where(id: params[:games].split(',').collect{|x| x.to_i })
    authorize! :read, Game if games.empty?
    games.each do |game|
      authorize! :read, game
    end
    @game_ids = games.pluck(:id)
    @results = PlayerResult.includes(:game_links).where(game_id: @game_ids, player_id: params[:player_id].to_i)
    @results.each do |result|
      authorize! :read, result
    end
    render json: @results, include: [:game_links]
  end

private

  def player_result_params
    params.permit(:game_id, :played_game, :goals, :own_goals, :subst_on, :subst_off, :rating,
                    :home_or_away, :sport, :minutes_played, :notes, :formation)
    # played_game, goals_scored, boots
  end

  def update_home_or_away_games
    if @result.team.id == @result.game.home_team.id
      @result.home_or_away = :home_game
    elsif @result.team.id == @result.game.away_team.id
      @result.home_or_away = :away_game
    else
      Rails.logger.warn "No home or away game! user=#{current_user.id}, team=#{@result.team.id}, game=#{@result.game.id}"
    end
  end

  def update_game_scores
    # Only first person can update a score
    game = Game.find(@result.game_id)
    game.update_attributes(home_team_score: params[:home_score].to_i, away_team_score: params[:away_score],
                           state: :final_score) unless game.home_team_score and game.away_team_score
  end

  def sort_order(x,y)
    # Coaches always come first
    return 1 if x.player.try(:active_sport_profile).try(:player_no) == 'C'
    return -1 if y.player.try(:active_sport_profile).try(:player_no) == 'C'

    # Otherwise, sort by integer player numbers (ascending)
    result = x.player.try(:active_sport_profile).try(:player_no).try(:to_i) <=>
              y.player.try(:active_sport_profile).try(:player_no).try(:to_i)
    return result if result

    # default to x followed by y (don't return a nil, or the sort will fail)
    1
  end

  def handle_game_links(result, pr_params)
    unless pr_params[:photo_link].blank?
      photo_link = result.game_links.where(kind: GameLink.kinds[:photos]).
          first_or_initialize(user: current_user)
      photo_link.update_attribute(:url, pr_params[:photo_link])
    else
      link = result.game_links.select { |gl| gl.kind == 'photos' }[0]
      link.try(:mark_for_destruction)
    end

    unless pr_params[:video_link].blank?
      add_video_link(result, pr_params)
    else
      link = result.game_links.select { |gl| gl.kind.start_with?('video') }[0]
      link.try(:mark_for_destruction)
    end
  end

  def add_video_link(result, pr_params)

    kinds = [:video, :video_youtube, :video_vimeo, :video_facebook].collect { |sym| GameLink.kinds[sym] }
    kind = GameLink.kinds[:video]
    link = pr_params[:video_link]

    youtube = %r{^(?:https?://)?(?:www\.)?youtu(?:\.be|be\.com)/(?:watch\?v=)?([\w-]{10,})}.match(link)
    if youtube
      kind = GameLink.kinds[:video_youtube]
      link = youtube[1]
    end

    vimeo = %r{^https://vimeo.com/(channels/[^/]+/)?(.+)$}.match(link)
    if vimeo
      kind = GameLink.kinds[:video_vimeo]
      link = vimeo[2]
    end

    # TODO: Facebook videos don't play on mobile devices (yet)
    facebook = %r{^https://www.facebook.com/([^/]+)/videos/(.+)$}.match(link)
    if facebook
      kind = GameLink.kinds[:video_facebook]
      link = "#{facebook[1]}/videos/#{facebook[2]}"
    end

    video_link = result.game_links.where(kind: kinds).first
    video_link ||= result.game_links.build(user: current_user)
    video_link.kind = kind
    video_link.url = link
    video_link.save!
  end

end
