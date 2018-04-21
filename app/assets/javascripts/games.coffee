@gamesError = () ->
#warning = angular.element(document.body.querySelector('#warning'))
  warning = $('#warning')
  warning.html("Error whilst loading or saving games data")
  warning.addClass('alert')
  warning.addClass('alert-warning')
  warning.show()

# Game controllers ################################################################################################

@GameCtrl = ($scope, $rootScope, $routeParams, $location, $window, $sce, $modal, sharedServices, screenSize, API, FileUploader) ->

#$scope.navCollapsed = window.innerWidth <= 990

# Toggle the left off-canvas navigation
#  $rootScope.$on '$viewContentLoaded', () ->
#    $('[data-toggle="offcanvas"]').click () ->
#      $('.row-offcanvas').toggleClass('active')

  $scope.page = 'schedule'
  $scope.page_title = 'Game Details'
  $scope.show_game_stats = false

  $scope.back_button = switch $scope.page
    when 'dashboard' then false
    else true

  # Shared services
  $scope.toggleButtonClass = (navCollapsed)   -> sharedServices.toggleButtonClass(navCollapsed)
  $scope.toggleSidebarClass = (navCollapsed)  -> sharedServices.toggleSidebarClass(navCollapsed)
  $scope.isGoalkeeper =                       -> sharedServices.isGoalkeeper($scope)
  $scope.isCoach =                            -> sharedServices.isCoach($scope)
  $scope.openMap = (game)                     -> sharedServices.openMap($scope, $modal, game)
  $scope.backClicked =                        -> sharedServices.backClicked($window)
  $scope.openGameData2 =                      -> sharedServices.openGameData2($scope, $modal, $rootScope, API)
  $scope.containsVideo = (game_links)         -> sharedServices.containsVideo($scope, game_links)
  $scope.containsImage = (game_links)         -> sharedServices.containsImage($scope, game_links)

  initGameData = ->
    game_data = new API.PlayerResults()
    game_data.sport = 'soccer'
    game_data.formation = 'Select'
    game_data.minutes_played = 0
    game_data.game_id = null
    game_data.played_game = 'false'
    game_data.goals = 0
    game_data.rating = null
    game_data.specialized = {}
    game_data.specialized.penalty_saves = 0
    game_data.specialized.assists = 0
    game_data.specialized.yellow_cards = 0
    game_data.specialized.red_cards = 0
    game_data.boots = null
    game_data

  $scope.addOrEditStats = 'Add stats'
  $scope.addOrEditClass = 'btn-primary'
  $scope.game_data = initGameData()
  $scope.forecast = {}


  ### Share animation handling ###
  $scope.share_visible = false
  $scope.share_visible2 = false
  $scope.share_visible3 = false

  $scope.toggleShare = ->
    $scope.share_visible = !$scope.share_visible

  $scope.toggleShare2 = ->
    $scope.share_visible2 = !$scope.share_visible2

  $scope.toggleShare3 = ->
    $scope.share_visible3 = !$scope.share_visible3

  $scope.retrievePlayerResults = ->
    API.Games.player_results({ id: $routeParams.id }, (results) ->
      $scope.player_results = results

      # Now split into home and away teams
      $scope.game.$promise.then (game) ->
        your_team_id = if $scope.current_user.team_id == game.home_team_id then game.home_team_id else game.away_team_id
        their_team_id = if $scope.current_user.team_id == game.home_team_id then game.away_team_id else game.home_team_id
        $scope.your_team = if game.home_team.id == your_team_id then game.home_team.name else game.away_team.name
        $scope.their_team = if game.home_team.id == your_team_id then game.away_team.name else game.home_team.name
        $scope.your_player_results = (result for result in $scope.player_results when result.team_id == your_team_id)
        $scope.their_player_results = (result for result in $scope.player_results when result.team_id == their_team_id)

      # Update the prior game with this player result
#      console.log(results)
#      results.forEach (player_result) ->
#        prior_game = game for game in $scope.prior_games when game.id == player_result.game_id

    , gamesError)

  ### Default map location: Wembly Stadium :) ###
  $scope.map = { center: {latitude: 51.556021, longitude: -0.279519}, zoom: 16, marker: {latitude: 51.556021, longitude: -0.279519} }

  # Update map details (once loaded)
  $scope.updateMapDetails = (game) ->
    $scope.unknown_address = true
    $scope.unknown_address = false if game? and game.venue? and game.venue.latitude? and game.venue.latitude?

    $scope.map.center.latitude = game.venue.latitude if game? and game.venue? and game.venue.latitude?
    $scope.map.center.longitude = game.venue.longitude if game? and game.venue? and game.venue.longitude?

    $scope.map.marker.latitude = $scope.map.center.latitude
    $scope.map.marker.longitude = $scope.map.center.longitude

  ### Game Data Modal ###
  $scope.obtainUsersTeamId = (game,user) ->
    return game.home_team_id if user.previous_teams.indexOf(game.home_team_id) != -1
    return game.away_team_id if user.previous_teams.indexOf(game.away_team_id) != -1
    console.log("no valid home or away team!")
    user.team_id

  $scope.openIndividualGameData2 = (game,user) ->
    # Switch to game page and then open modal through a unique route
    #$location.url('/users/' + $rootScope.current_user.id + '/games/' + game.id + '/played/edit')

    # Previous implementation (show on same screen)
    filtered = (result for result in $scope.player_results when result.game_id == game.id)
    if filtered.length > 0
      $scope.game_data = new API.PlayerResults(filtered[0])
    else
      $scope.game_data = initGameData()
    $scope.game_data.game_id = game.id
    $scope.game_data.game = game
    $scope.game_data.team_id = $scope.obtainUsersTeamId(game,user)
    $scope.game_data.prior_score = game.home_team_score? && game.away_team_score?
    sharedServices.openGameData2($scope, $modal, $rootScope, $routeParams, $location, API)

  $scope.otherTeam = (game) ->
    if game.home_or_away is 'home' then game.away_team else game.home_team

  $rootScope.current_user = API.Users.current_user { id:$routeParams.user_id }, (user) ->

    # If the user is not logged in, force them to do so now
    unless user.id?
      $rootScope.user_logged_out = true
      window.location.pathname = '/user_sessions/new'
      return

    if $routeParams.user_id
      API.Users.get { id:$routeParams.user_id }, (user) ->
        $scope.show_game_stats = true
        $scope.user = user
        $rootScope.current_user.$promise.then ->
          $scope.user.current = ($scope.current_user.id == $scope.user.id)
      , gamesError
      #      if user.team?
      #        API.Teams.with_games {id: user.team.id}, (team) ->
      #          $scope.user.team = team
      #        , dashboardError
    else
      $scope.user = {}

    if $routeParams.id
      $scope.game = API.Games.get { id:$routeParams.id }, (game) ->
        $scope.team = game.home_team
        # Update the map with this game
        $scope.updateMapDetails(game)
      , gamesError
      $scope.retrievePlayerResults()

      API.Games.weather_forecast {id: $routeParams.id}, (forecast) ->
        $scope.forecast = forecast
        $scope.forecast.description += ' - on ' + $scope.forecast.date_s if $scope.forecast.result == 'too_far_ahead'
      , dashboardError

      if $routeParams.user_id
        API.PlayerResults.from_game { game_id: $routeParams.id, player_id: $routeParams.user_id }, (data) ->
          $scope.game_data = data
          $scope.game_data.game_id = $routeParams.id
          if data.id?
            $scope.addOrEditStats = 'Edit stats'
            $scope.addOrEditClass = 'btn-default'

            # Show the modal if we are in edit mode (now we have the game data)
            edit = $location.url().split('/')[6]
            if edit? and edit is 'edit'
              sharedServices.openGameData2($scope, $modal, $rootScope, API)

        , gamesError


    else
      $scope.game = []
      $scope.team = {}
      $scope.player_results = []


  , gamesError

  $scope.active = $location.url().split('/')[3]
  $scope.is_active = (test) ->
    if test == $scope.active
      'active'
    else
      ''

  $scope.showingStats = true
  $scope.homeTeam = true

  # Avatar uploader and cropping
  $scope.uploadAvatar = false
  $scope.uploadAvatarNow = () ->
    $scope.uploadAvatar = true

  csrf_token = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
  $scope.uploader = new FileUploader({
    url: '/users/upload',
    autoUpload: true,
    headers : { 'X-CSRF-TOKEN': csrf_token },
    onCompleteItem: (item, response, status, headers) ->
      $scope.user = transformUser(response)
      $scope.uploadAvatar = false
    onErrorItem: (item, response, status, headers) ->
      $('#warning').html("Error whilst uploading avatar")
      $('#warning').addClass('alert')
      $('#warning').addClass('alert-warning')
      $('#warning').show
      $scope.uploadAvatar = false
  })

  $scope.searchAddress = (game) ->
    return '' unless game? and game.venue?
    $sce.trustAsUrl('https://www.google.com/maps/embed/v1/place?q=' + encodeURI(game.venue.full_address) + '&key=AIzaSyDoNFNCUWv6-1XkOGJOHyEZd2aLU-hgqJ4').toString()

  $scope.clubLogo = (team) ->
    return '/img/no-club-logo.gif' unless team? and team.club? and team.club.logo? and team.club.logo.url?
    team.club.logo.url

  $scope.dateOnly = (date) ->
    d = new Date(date)
    d.getDay() + '/' + d.getMonth() + '/' + d.getFullYear()

  $scope.showStats = () ->
    $scope.showingStats = true

  $scope.showPlayers = () ->
    $scope.showingStats = false

  $scope.teamName = (team) ->
    return '' unless team?
    if team.club? then (team.club.name + ' [' + team.name + ']') else team.name

  $scope.showHomeTeam = (homeTeam) ->
    $scope.homeTeam = homeTeam
    if homeTeam
      $scope.team = $scope.game.home_team
    else
      $scope.team = $scope.game.away_team

  $scope.homeWinner = (game) ->
    return '' unless game?
    if game.home_team_score > game.away_team_score then 'winner' else ''

  $scope.awayWinner = (game) ->
    return '' unless game?
    if game.home_team_score < game.away_team_score then 'winner' else ''

  $scope.linkTitle = (link) ->
    return '' unless link?
    return 'View Photos' if link.kind == 'photos'
    return 'View Video' if link.kind == 'video'
    return 'Youtube' if link.kind == 'video_youtube'
    return 'Vimeo' if link.kind == 'video_vimeo'
    return 'View Facebook Video' if link.kind == 'video_facebook'
    return link.url

#  $scope.isEmbedVideo = (link) ->
#    switch link.kind
#      when 'photo', 'video' then false
#      when 'video_youtube' then true
#      when 'video_vimeo' then true
#      when 'video_facebook' then true
#      else false

  $scope.isPhoto = (link) ->
    link.kind == 'photos'

  $scope.isYoutubeVideo = (link) ->
    link.kind == 'video_youtube'

  $scope.isUnknownVideo = (link) ->
    link.kind == 'video'

  $scope.isVimeoVideo = (link) ->
    link.kind == 'video_vimeo'

  $scope.isFacebookVideo = (link) ->
    link.kind == 'video_facebook'

  $scope.facebookVideoUrl = (link) ->
    return '' unless link?
    $sce.trustAsUrl('https://www.facebook.com/' + link.url)

#  $scope.containsPhotos = (game_links) ->
#    return false unless game_links?
#    photos = (link for link in game_links when link.kind == 'photos')
#    return photos.length > 0

  $scope.isMobile = screenSize.on 'xs', (isMatch) ->
    $scope.isMobile = isMatch

  $scope.isTablet = screenSize.on 'sm, md', (isMatch) ->
    $scope.isTablet = isMatch

  $scope.whosMatchStats = () ->
    return '' unless $rootScope.current_user? and $scope.user?
    if $rootScope.current_user.id == $scope.user.id
      'My'
    else
      return '' unless $scope.user.first_name?
      $scope.user.first_name + "'s"

  $scope.teamGoalsScored = ->
    return '' unless $scope.game?
    if $scope.game.home_or_away is 'home' then $scope.game.home_team_score else $scope.game.away_team_score

  $scope.teamGoalsConceded = ->
    return '' unless $scope.game?
    if $scope.game.home_or_away is 'home' then $scope.game.away_team_score else $scope.game.home_team_score


  ### Game Data Modal ###

ngApp.controller('GameCtrl', ['$scope', '$rootScope', '$routeParams', '$location', '$window', '$sce', '$modal', 'sharedServices', 'screenSize', 'API', 'FileUploader', GameCtrl])
