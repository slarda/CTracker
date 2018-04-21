
### Error handling ###
@dashboardError = (e) ->
  console.log('dashboard error')
  if e.data? and e.data.error?
    console.log(e.data.error)
    $('#warning').html(e.data.error)
  else
    console.log(e)
    $('#warning').html("Error whilst loading or saving dashboard data")
  $('#warning').addClass('alert')
  $('#warning').addClass('alert-warning')
  $('#warning').show()
  setTimeout ->
    $('#warning').fadeOut()
  , 2000

@userDoesntExistError = (e) ->
  $('#warning').html('This user doesn\'t exist')
  $('#warning').addClass('alert')
  $('#warning').addClass('alert-warning')
  $('#warning').show()
  setTimeout ->
    $('#warning').fadeOut()
  , 2000


@loadingUserFailed = ->
  $('#warning').html("Cannot load user data. Have you logged in successfully? <a href='/logout'>Logout Now</a>")
  $('#warning').addClass('alert')
  $('#warning').addClass('alert-warning')
  $('#warning').show()
  setTimeout ->
    $('#warning').fadeOut()
  , 5000


### Global convenience functions ###
@addHours = (d,h) ->
  d.setHours(d.getHours() + h)
  d

### Award Modal controller - award edit ###
@AwardModalCtrl = ($scope, $modalInstance, award, user) -> 
  $scope.award = award
  $scope.user = user

  $scope.save = () ->
    if award.id
      index = $scope.user.awards.map((a) -> a.id ).indexOf($scope.award.id)
      $scope.user.awards[index] = $scope.award
    else
      $scope.user.awards.push($scope.award)

    $scope.user.$update((result) ->
      console.log(result)
      $modalInstance.dismiss('cancel')
    , (error) -> 
      console.log(error)
      $modalInstance.dismiss('cancel')
    )

  $scope.cancel = ->
    $modalInstance.dismiss('cancel')

### Media Modal controller - media add ###
@MediaModalCtrl = ($scope, $modalInstance, media, user) -> 
  $scope.media = media
  $scope.user = user

  $scope.save = () ->
    if media.id
      index = $scope.user.media_sections.map((a) -> a.id ).indexOf($scope.media_sections.id)
      $scope.user.media_sections[index] = $scope.media
    else
      $scope.user.media_sections.push($scope.media)

    $scope.user.$update((result) ->
      console.log(result)
      $modalInstance.dismiss('cancel')
    , (error) -> 
      console.log(error)
      $modalInstance.dismiss('cancel')
    )

  $scope.cancel = ->
    $modalInstance.dismiss('cancel')


### Modal controller - map view ###
@MapModalInstanceCtrl = ($scope, $modalInstance, $sce, map, game, unknown_address) ->
  $scope.map = map
  $scope.game = game
  $scope.unknown_address = unknown_address
  $scope.render = true

  $scope.searchAddress = (game) ->
    return '' unless game? and game.venue?
    # Embedded is .../embed/v1/place/?q=..., key is ...&key=googleApi...
    $sce.trustAsUrl('https://www.google.com/maps/?q=' + encodeURI(game.venue.full_address)).toString()

  $scope.cancel = ->
    $modalInstance.dismiss('cancel')


### Modal controller - add/edit game data modal ###
@GameDataModalInstanceCtrl = ($scope, $modalInstance, $location, $routeParams, $filter, sharedServices, data, user) ->
  $scope.data = data
  $scope.data.played_game = if $scope.data.played_game? then $scope.data.played_game.toString() else 'true'
  $scope.data.rating = null if $scope.data.rating is undefined
  $scope.data.show_rating = true
  $scope.user = user

  $scope.playedOrCoached = ->
    return 'coach' if $scope.isCoach()
    'play in'

  $scope.isGoalkeeper = -> sharedServices.isGoalkeeper($scope)
  $scope.isCoach = -> sharedServices.isCoach($scope)
  $scope.isRep = (rep) -> sharedServices.isRep($scope, rep)
  $scope.clubLogo = (team) -> sharedServices.clubLogo($scope, team)
  $scope.enhanceClubName = (team) -> sharedServices.enhanceClubName($scope, team)
  $scope.homeWinner = (game) -> sharedServices.homeWinner($scope, game)
  $scope.awayWinner = (game) -> sharedServices.awayWinner($scope, game)
  $scope.selectFormation = (formation) -> sharedServices.selectFormation($scope, formation)

  $scope.checkInts = (ev) ->
    # Only allow 0-9 keyboard entry, or tab for switching fields
    if (ev.which < 48 or ev.which > 57) and ev.which != 9 and ev.which != 8 and ev.which != 37 and ev.which != 39 and ev.which != 46
      ev.preventDefault()

  if $scope.isCoach()
    $scope.max_yellow = 20
    $scope.max_red = 3
  else
    $scope.max_yellow = 2
    $scope.max_red = 1

  # Rating dropdown
  $scope.status = {
    isopen: false
  }
  $scope.rating5 = 5
  $scope.rating4 = 4
  $scope.rating3 = 3
  $scope.rating2 = 2
  $scope.rating1 = 1

  $scope.setRating = (rating) ->
    $scope.data.rating = rating

#  $scope.toggled = (ev) ->
#    ev.preventDefault()
#    ev.stopPropagation()
#    $scope.status.isopen = !$scope.status.isopen


  $scope.save = ->
    $('body').removeClass('modal-open')
    if $scope.form.$valid
      $modalInstance.close($scope.data)
      # Remove the 'edit' route
      #$location.url('/users/' + $routeParams.user_id + '/games/' + $routeParams.id + '/played')

  $scope.cancel = ->
    $('body').removeClass('modal-open')
    $modalInstance.dismiss('cancel')
    # Remove the 'edit' route
    #$location.url('/users/' + $routeParams.user_id + '/games/' + $routeParams.id + '/played')


### Primary dashboard controller ###
@DashboardCtrl = ($scope, $rootScope, $routeParams, $location, $window, $sce, $modal, screenSize, sharedServices, API, FileUploader) ->

  $scope.isMobile = screenSize.on 'xs', (isMatch) ->
    $scope.isMobile = isMatch

  #$scope.navCollapsed = window.innerWidth <= 990

  $scope.page = $location.url().split('/')[3]
  $scope.page_title = switch $scope.page
    when 'dashboard' then 'Dashboard'
    when 'schedule' then 'Schedule'
    when 'standings' then 'Standings'
    when 'player_profiles' then 'Profile'
    else 'Dashboard'

  #if $location.url().split('/')[1] is 'player_profiles'
  #  $scope.page_title = 'Profile'

  # Shared services
  $scope.toggleButtonClass = (navCollapsed)   -> sharedServices.toggleButtonClass(navCollapsed)
  $scope.toggleSidebarClass = (navCollapsed)  -> sharedServices.toggleSidebarClass(navCollapsed)
  $scope.openMap = (game)                     -> sharedServices.openMap($scope, $modal, game)
  $scope.backClicked =                        -> sharedServices.backClicked($window)
  $scope.openGameData =                       -> sharedServices.openGameData($scope, $modal, $rootScope, $routeParams, $location, API)
  $scope.currentYear =                        -> sharedServices.currentYear()
  $scope.clubLogo = (team)                    -> sharedServices.clubLogo($scope, team)
  $scope.enhanceClubName = (team)             -> sharedServices.enhanceClubName($scope, team)
  $scope.homeWinner = (game)                  -> sharedServices.homeWinner($scope, game)
  $scope.awayWinner = (game)                  -> sharedServices.awayWinner($scope, game)
  $scope.isCoach =                            -> sharedServices.isCoach($scope)
  $scope.containsVideo = (game_links)         -> sharedServices.containsVideo($scope, game_links)
  $scope.containsImage = (game_links)         -> sharedServices.containsImage($scope, game_links)

  $scope.parseVideo = (link) ->
    youtube_reg = /^(?:https?:\/\/)?(?:www\.)?youtu(?:\.be|be\.com)\/(?:watch\?v=)?([\w-]{10,})$/g
    youtube = youtube_reg.exec(link)
    if youtube
      return {'kind': 'youtube', 'url': youtube[1]}

    vimeo_reg = /^https:\/\/vimeo.com\/(channels\/[^/]+\/)?(.+)$/g
    vimeo = vimeo_reg.exec(link)
    if vimeo
      return {'kind': 'vimeo', 'url': vimeo[1]}

    facebook_reg = /^https:\/\/www.facebook.com\/([^/]+)\/videos\/(.+)$/g
    facebook = facebook_reg.exec(link)
    if facebook
      return {'kind': 'facebook', 'url': facebook[1]}

    false

  $scope.isPhoto = (link) ->
    link.kind == 'photos'

  $scope.isYoutubeVideo = (link) ->
    link.indexOf('youtube') > -1

  $scope.isVimeoVideo = (link) ->
    link.indexOf('vimeo') > -1

  $scope.isFacebookVideo = (link) ->
    link.indexOf('facebook') > -1

  $scope.isUnknownVideo = (link) ->
    link.indexOf('youtube') == link.indexOf('vimeo') == link.indexOf('facebook')

  $scope.facebookVideoUrl = (link) ->
    return '' unless link?
    $sce.trustAsUrl('https://www.facebook.com/' + link.url)

  $scope.linkTitle = (link) ->
    return '' unless link?
    return 'View Photos' if link.kind == 'photos'
    return 'View Video' if link.kind == 'video'
    return 'Youtube' if link.kind == 'video_youtube'
    return 'Vimeo' if link.kind == 'video_vimeo'
    return 'View Facebook Video' if link.kind == 'video_facebook'
    return link.url

  $scope.back_button = switch $scope.page
    when 'dashboard' then false
    else true

  $scope.getArray = (n) ->
    return [] unless n
    new Array(n)

  $scope.didntPlayGame = (player_stat) ->
    return false unless player_stat?
    !player_stat.played_game

  ### Refactored functions ###
  $scope.noUserDefaults = ->
    $scope.user = {}
    $scope.season_stats = []
    $scope.current_stat = {}
    $scope.prior_games = []
    $scope.team_games = []
    $scope.previous_meetings = []
    $scope.unknown_address = true

  # Get all prior player results for fixture screen
  $scope.retrieveAllPlayerResults = (past_game_ids) ->
    API.PlayerResults.from_games { games: past_game_ids.join(','), player_id: $scope.user.id }, (results) ->
      $scope.player_results = results
      #console.log('player results retrieved')
      for game in $scope.prior_games
        found = false
        for result in $scope.player_results
          if result.game_id == game.id
            #console.log('game found')
            game.btn_class = 'btn-default'
            game.btn_text = 'Edit stats'
            game.player_stat = result
            found = true
            break
        unless found
          #console.log('game NOT found')
          game.btn_class = 'btn-primary'
          game.btn_text = 'Add stats'
    , dashboardError

  # Update prior games (once loaded)
  $scope.updatePriorGamesAndLastMatch = (user, games) ->
    $scope.prior_games = games

    if $location.url().split('/')[3] is 'schedule'
      game_ids = (g.id for g in $scope.prior_games)
      $scope.retrieveAllPlayerResults(game_ids)

    else
      if games[0]?
        $scope.game_data.game_id = games[0].id

        # Get any existing match data for this player and this game
        if user?
          API.PlayerResults.from_game {game_id: games[0].id, player_id: user.id}, (result) ->
            $scope.game_data = result
            $scope.game_data.game_id = games[0].id
            if result.id?
              $scope.addOrEditStats = 'Edit stats'
              $scope.addOrEditClass = 'btn-default'
          , dashboardError

  # Update map details (once loaded)
  $scope.updateMapDetails = (game) ->
    $scope.unknown_address = true
    if game? and game.venue? and game.venue.latitude? and game.venue.latitude?
      $scope.unknown_address = false
    else
      $scope.map = angular.copy($scope.default_map)
      return

    $scope.map.center.latitude = game.venue.latitude if game? and game.venue? and game.venue.latitude?
    $scope.map.center.longitude = game.venue.longitude if game? and game.venue? and game.venue.longitude?

    $scope.map.marker.latitude = $scope.map.center.latitude
    $scope.map.marker.longitude = $scope.map.center.longitude


  # Get any previous meetings between the teams
  $scope.getPreviousTeamMeetings = (team) ->
    next_game = team.future_games[0]
    if next_game?
      home_team_id = next_game.home_team.id
      away_team_id = next_game.away_team.id

      $scope.previous_meetings = API.Teams.previous_meetings {
        id: next_game.home_team.id,
        other_team: next_game.away_team.id,
        sport: $scope.game_data.sport
      }, success, dashboardError
    else
      $scope.previous_meetings = {team1: [], team2: []}

  # Get the team's own games (if changed)
  $scope.getTeamGamesIfChangedTeams = (user) ->
    if user.team_changed_at?
      API.Users.team_games {id: user.id}, (games) ->
        $scope.team_games = games
    else
      $scope.team_games = []

  $scope.isGoalkeeper = -> sharedServices.isGoalkeeper($scope)

  ### Default values ###
  $scope.futureGames = true
  $scope.currentSeason = new Date().getFullYear().toString()
  $scope.forecast = {}

  ### Default map location: Wembly Stadium :) ###
  $scope.default_map = { center: {latitude: 51.556021, longitude: -0.279519}, zoom: 16, marker: {latitude: 51.556021, longitude: -0.279519} }
  $scope.map = angular.copy($scope.default_map)


  initGameData = ->
    game_data = new API.PlayerResults()
    game_data.sport = 'soccer'
    game_data.formation = 'Select'
    game_data.minutes_played = 0
    game_data.game_id = null
    game_data.played_game = 'true'
    game_data.goals = 0
    game_data.rating = null
    game_data.specialized = {}
    game_data.specialized.penalty_saves = 0
    game_data.specialized.assists = 0
    game_data.specialized.yellow_cards = 0
    game_data.specialized.red_cards = 0
    game_data.boots = null
    game_data.notes = ''
    game_data

  ### Player result defaults ###
  $scope.addOrEditStats = 'Add stats'
  $scope.addOrEditClass = 'btn-primary'
  $scope.game_data = initGameData()

  ### Update the seasons stats when the user selects a different year from the drop-down ###
  $scope.updateSeasonStats = (stats) ->
    $scope.season_stats = stats.by_season
    $scope.all_stats = stats.all_time
    $scope.currentSeason = if $scope.season_stats.length > 0 then $scope.season_stats[0].season else new Date().getFullYear().toString()
    $scope.current_stat =
      if $scope.season_stats.length > 0
        (stat for stat in $scope.season_stats when stat.season == $scope.currentSeason)[0]
      else {}

    if $location.url().split('/')[3] is 'dashboard'
      $scope.percent1 = if $scope.current_stat.team_games > 0
        $scope.current_stat.games * 100 / $scope.current_stat.team_games
      else 100 # default 100%
      $scope.percent2 = 100
        #if $scope.current_stat.team_games > 0
        #  $scope.current_stat.win * 100 / $scope.current_stat.team_games
        #else 100 # default 100%
      $scope.percent3 = 100

    # Get the standings
    if $location.url().split('/')[3] is 'standings'
      $scope.setCurrentStatStandings($scope.current_stat)

  $scope.getTeamDetails = (user, team_id, all_teams = false) ->
    hash = {id: team_id, sport: (if all_teams then 'all' else $scope.game_data.sport)}
    hash['user_id'] = user.id if user?
    API.Teams.with_games hash, (team) -> # , future_only: 1
      $scope.user.team = team

      # TODO: future games for future seasons do not show up on the schedule page. Maybe this doesn't matter though,
      # because normally users are added to new teams for the next season
      if team.past_games?
        $scope.updatePriorGamesAndLastMatch(user,team.past_games)
        $scope.currentSeason = team.past_games[0].season if team.past_games[0]

      # Update the map for the address of the future game
      $scope.updateMapDetails(team.future_games[0])

      # If there is a future game for this player's team, then look for the previous meetings of those
      # two teams
      $scope.getPreviousTeamMeetings(team)

      if team.future_games.length > 0
        API.Games.weather_forecast {id: team.future_games[0].id}, (forecast) ->
          $scope.forecast = forecast
          #$scope.forecast.description += ' - on ' + $scope.forecast.date_s if $scope.forecast.result == 'too_far_ahead'
        , dashboardError

      # API.Teams.previous_team_games({team_ids: user.previous_teams.join(',')}, (historical) ->
      # , dashboardError)

    , dashboardError


  ### This part does the bulk of the initial data-loading on the dashboard ###
  $rootScope.current_user = API.Users.get({ id:$routeParams.user_id }, (user) ->

    # If the user is not logged in, force them to do so now
    # unless user.id?
    #   $rootScope.user_logged_out = true
    #   window.location.pathname = '/user_sessions/new'
    #   return

    $scope.user = user;

    if $scope.user.player_profile.highlights_video
      $scope.user.highlights_video = $scope.parseVideo($scope.user.player_profile.highlights_video);

    if $routeParams.user_id
      # First, load the user
      $scope.game_data.sport = user.active_sport

      $rootScope.current_user.$promise.then ->
        $scope.user.current = ($scope.current_user.id == $scope.user.id)

      # Get the user's season stats
      # season_page = $location.url().split('/')[3]
      all_games = 1 # if season_page is 'schedule' or season_page is 'standings'
      API.Users.season_stats { id: $routeParams.user_id, sport: $scope.game_data.sport, all_games: all_games }, (stats) ->
        $scope.updateSeasonStats(stats)
      , dashboardError

      API.Users.playing_career { id: $routeParams.user_id, sport: $scope.game_data.sport, all_games: all_games }, (careers) ->
        $scope.playing_careers = careers
      , dashboardError

      # Get the user's own prior games (as opposed to their team's prior games)
      #
      # NOTE: This also updates the last game ID for match data updates
      #
      #      API.Users.prior_games({id: user.id}, (games) ->
      #        $scope.updatePriorGamesAndLastMatch(user,games)
      #      , dashboardError)

      # If the user has changed their team, then we should also get their team's prior games for
      # all the teams that they previously played within
      $scope.getTeamGamesIfChangedTeams(user)

      # If the user has a team...
      if user.team?

        # Get the details of that user's team, including the team's previous and future games
        #
        # NOTE: The issue here is that a particular player may not have been with the team for their entire
        # previous game history, nor will they have necessarily played every game either. We need to correlate
        # this against the player result details.
        #
        $scope.getTeamDetails(user, user.team_id)

  , () ->
    console.log("not logged in")
  )


  if $routeParams.team_id
    $rootScope.current_user.$promise.then ->
      all_sports = $location.url().split('/')[1] == 'teams'
      $scope.getTeamDetails(null, $routeParams.team_id, all_sports)

  ### Loading of the active menu item ###
  $scope.active = $location.url().split('/')[3]
  $scope.is_active = (test) ->
    if test == $scope.active
      'active'
    else
      ''

  ### Avatar uploader and cropping ###
  $scope.uploadAvatar = false
  $scope.uploadAvatarNow = () ->
    $scope.uploadAvatar = true


  ### Easy Pie Chart ###
  $scope.percent1 = 0
  $scope.options1 = {
    animate: {
      duration: 1200,
      enabled: true
    },
    barColor: '#ff206f',
    trackColor: false,
    scaleColor: false,
    lineCap: 'round',
    lineWidth: 8,
    size: 120
  }

  $scope.percent2 = 0
  $scope.options2 = {
    animate: {
      duration: 1200,
      enabled: true
    },
    barColor: '#03a4cc',
    trackColor: false,
    scaleColor: false,
    lineCap: 'round',
    lineWidth: 8,
    size: 120
  }

  $scope.percent3 = 0
  $scope.options3 = {
    animate: {
      duration: 1200,
      enabled: true
    },
    barColor: '#a1d417',
    trackColor: false,
    scaleColor: false,
    lineCap: 'round',
    lineWidth: 8,
    size: 120
  }

  ### Map Modal ###
  $scope.openMapForGame = (game) ->
    $scope.updateMapDetails(game)
    $scope.openMap(game)

  ### Game Data Modal ###
  $scope.obtainUsersTeamId = (game,user) ->
    return game.home_team_id if user.previous_teams.indexOf(game.home_team_id) != -1
    return game.away_team_id if user.previous_teams.indexOf(game.away_team_id) != -1
    console.log("no valid home or away team!")
    user.team_id

  $scope.openIndividualGameData = (game,user) ->
    # Switch to game page and then open modal through a unique route
      #$location.url('/users/' + $rootScope.current_user.id + '/games/' + game.id + '/played/edit')

    # Previous implementation (show on same screen)
    filtered = (result for result in $scope.player_results when result.game_id == game.id)
    if filtered.length > 0
      $scope.game_data = filtered[0]
    else
      $scope.game_data = initGameData()
    $scope.game_data.game_id = game.id
    $scope.game_data.game = game
    $scope.game_data.home_score = game.home_team_score
    $scope.game_data.away_score = game.away_team_score
    $scope.game_data.prior_score = game.home_team_score? && game.away_team_score?
    $scope.game_data.team_id = $scope.obtainUsersTeamId(game,user)
    sharedServices.openGameData($scope, $modal, $rootScope, $routeParams, $location, API)

  $scope.openDashboardPageGameData = (game,user) ->
    $scope.game_data.game_id = game.id
    $scope.game_data.game = game
    $scope.game_data.home_score = game.home_team_score
    $scope.game_data.away_score = game.away_team_score
    $scope.game_data.prior_score = game.home_team_score? && game.away_team_score?
    #$scope.game_data.team_id = $scope.obtainUsersTeamId(game,user)
    sharedServices.openGameData($scope, $modal, $rootScope, $routeParams, $location, API)

  $scope.openAwardModal = (award) ->
    $scope.award = award
    teams = []
    sharedServices.openAward($scope, $modal, award, $scope.user)

  $scope.openMediaModal = (media) ->
    $scope.media = media
    sharedServices.openMedia($scope, $modal, media, $scope.user)

  ### Uploader for new avatar photos ###
  csrf_token = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
  $scope.uploader = new FileUploader({
    url: '/users/upload',
    autoUpload: true,
    headers : { 'X-CSRF-TOKEN': csrf_token },
    onCompleteItem: (item, response, status, headers) ->
      $scope.user = transformUser(response)
      $scope.uploadAvatar = false
      $('#warning').html("Upload complete!")
      $('#warning').show()

    # TODO: Remove this - only used for temporary admin of avatars (must be 'super admin' anyway)
    onBeforeUploadItem: (item) ->
      item.formData.push {user_id: $scope.user.id}

    onErrorItem: (item, response, status, headers) ->
      $('#warning').html("Error whilst uploading avatar")
      $('#warning').addClass('alert')
      $('#warning').addClass('alert-warning')
      $('#warning').show()
      $scope.uploadAvatar = false
  })


  ### UI functions for on-screen rendering ###
  $scope.otherTeam = (game) ->
    if game.home_or_away is 'home' then game.away_team else game.home_team

  $scope.isAwayClass = (game,reversed) ->
    return '' unless game?
    return '' if (game.home_or_away is 'unknown')
    if (game.home_or_away is 'home') isnt reversed then 'home' else 'away'

  $scope.showMoreFixture = () ->
    $location.url('/users/' + $routeParams.user_id + '/fixture-more')

  $scope.showMatchDetails = () ->
    $location.url('/users/' + $routeParams.user_id + '/match-details')

  $scope.enhanceLeagueName = (team) ->
    return '' unless team? and team.league?
    team.league.name + (if team.name != team.league.name then ' [' + team.name + ']' else '')

  $scope.teamName = (team) ->
    return '' unless team?
    if team.club? then (team.club.name + ' [' + team.name + ']') else team.name

  $scope.otherTeamName = (game) ->
    return '' unless game?
    other_team = $scope.otherTeam(game)
    if other_team.club? then (other_team.club.name + ' [' + other_team.name + ']') else other_team.name

  $scope.searchAddress = (game) ->
    return '' unless game? and game.venue?
    $sce.trustAsUrl('https://www.google.com/maps/embed/v1/place?q=' + encodeURI(game.venue.full_address) + '&key=' + googleApi).toString()

  $scope.handedness = (user) ->
    return '' unless user? and user.player_profile?
    return 'Left' if user.player_profile.handedness is 'left_foot'
    return 'Right' if user.player_profile.handedness is 'right_foot'
    return ''

  $scope.showProfileHeader = (cell) ->
    return '' unless $scope.user?
    return $scope.showCoachHeader(cell) if $scope.user.active_sport_profile? and $scope.user.active_sport_profile.position == 'Coach'
    return $scope.showCoachHeader(cell) if $scope.user.active_sport_profile? and $scope.user.active_sport_profile.position == 'Assistant Coach'
    return 'Height:' if cell == 2 #and $scope.user.player_profile.height_cm?
    return 'Weight:' if cell == 3 #and $scope.user.player_profile.weight_kg?
    return 'Born:' if cell == 4
    return 'Natural Foot:' if cell == 5

  $scope.showCoachHeader = (cell) ->
    return 'Born:' if cell == 2

  $scope.showProfileData = (cell) ->
    return '' unless $scope.user?
    return $scope.showCoachData(cell) if $scope.user.active_sport_profile? and $scope.user.active_sport_profile.position == 'Coach'
    return $scope.showCoachData(cell) if $scope.user.active_sport_profile? and $scope.user.active_sport_profile.position == 'Assistant Coach'
    if $scope.user.player_profile?
      return $scope.user.player_profile.height_cm + " cm" if cell == 2 and $scope.user.player_profile.height_cm?
      return $scope.user.player_profile.weight_kg + " kg" if cell == 3 and $scope.user.player_profile.weight_kg?
      return $scope.handedness($scope.user) if cell == 5
    return $scope.user.nationality if cell == 4

  $scope.showCoachData = (cell) ->
    return $scope.user.nationality if cell == 2

  $scope.showTeamGame = (team) ->
    team? and team.future_games? and team.future_games.length > 0

  $scope.showLastGame = (user) ->
    return false unless $scope.prior_games?
    $scope.prior_games.length > 0

  $scope.playedOrCoached = ->
    return '' unless $scope.user?
    return 'coached' if $scope.user.active_sport_profile? and $scope.user.active_sport_profile.position == 'Coach'
    return 'coached' if $scope.user.active_sport_profile? and $scope.user.active_sport_profile.position == 'Assistant Coach'
    'played'

  $scope.showGoalsOrCleanSheets = ->
    return '' unless $scope.current_stat?
    return $scope.current_stat.clean_sheets if $scope.user.active_sport_profile? and $scope.user.active_sport_profile.position == 'Goalkeeper'
    $scope.current_stat.goals

  $scope.showGoalsTitle = ->
    return '' unless $scope.user?
    return 'clean sheets' if $scope.user.active_sport_profile? and $scope.user.active_sport_profile.position == 'Goalkeeper'
    return 'goals scored' if $scope.user.active_sport_profile? and $scope.user.active_sport_profile.position == 'Coach'
    return 'goals scored' if $scope.user.active_sport_profile? and $scope.user.active_sport_profile.position == 'Assistant Coach'
    'goals'

  $scope.showAssistsOrConceded = ->
    return '' unless $scope.current_stat?
    return $scope.current_stat.team_conceded if $scope.user.active_sport_profile? and $scope.user.active_sport_profile.position == 'Coach'
    return $scope.current_stat.penalty_saves if $scope.user.active_sport_profile? and $scope.user.active_sport_profile.position == 'Goalkeeper'
    $scope.current_stat.assists

  $scope.showAssistsTitle = ->
    return '' unless $scope.user?
    return 'goals conceded' if $scope.user.active_sport_profile? and $scope.user.active_sport_profile.position == 'Coach'
    return 'goals conceded' if $scope.user.active_sport_profile? and $scope.user.active_sport_profile.position == 'Assistant Coach'
    return 'penalties saved' if $scope.user.active_sport_profile? and $scope.user.active_sport_profile.position == 'Goalkeeper'
    'assists'

  $scope.assistsClass = ->
    return '' unless $scope.user?
    return 'cticon-goal2' if $scope.user.active_sport_profile? and $scope.user.active_sport_profile.position == 'Coach'
    return 'cticon-goal2' if $scope.user.active_sport_profile? and $scope.user.active_sport_profile.position == 'Assistant Coach'
    return 'cticon-goal-save' if $scope.user.active_sport_profile? and $scope.user.active_sport_profile.position == 'Goalkeeper'
    'cticon-strategy2'

  $scope.playerAge = (user) ->
    return '' unless user? and user.dob?
    today = new Date()
    birthDate = new Date(user.dob)
    age = today.getFullYear() - birthDate.getFullYear()
    month = today.getMonth() - birthDate.getMonth()
    age -= 1 if month < 0 or (month == 0 && today.getDate < birthDate.getDate)
    age

  $scope.showFutureGames = () ->
    $scope.futureGames = true

  $scope.showPastGames = () ->
    $scope.futureGames = false

  $scope.prevRoundDetails = (team) ->
    return '' unless team? and team.past_games? and team.past_games.length > 0
    return '' unless team.past_games[0].round
    "- Round #{team.past_games[0].round}"

  $scope.roundDetails = (team) ->
    return '' unless team? and team.future_games? and team.future_games.length > 0
    return '' unless team.future_games[0].round
    "- Round #{team.future_games[0].round}"

  $scope.isFinished = (game) ->
    return (new Date(game.end_date) <= new Date()) if game.end_date
    return (addHours(new Date(game.start_date),4) <= new Date())

  $scope.positions = (user) ->
    return '' unless user and user.positions
    (pos.position for pos in user.positions).join(', ')

  $scope.setCurrentStatStandings = (stat) ->
    return unless stat?
    unless $scope.user.team? and $scope.user.team.league?
      console.log('no league details')
      return
    $scope.current_stat = stat
    API.Leagues.standings { id: $scope.user.team.league.id, season: stat.season }, (standings) ->
      $scope.standings = standings

  $scope.setCurrentStat = (stat) ->
    $scope.last_season = $scope.current_stat.season
    $scope.current_stat = stat
    $scope.percent1 = if $scope.current_stat.team_games > 0 then $scope.current_stat.games * 100 / $scope.current_stat.team_games else 100 # default 100%
    $scope.percent2 = 100 #if $scope.current_stat.team_games > 0 then $scope.current_stat.win * 100 / $scope.current_stat.team_games else 100 # default 100%
    $scope.percent3 = 100

  $scope.setCurrentSeason = (stat) ->
    $scope.currentSeason = stat

  $scope.selectedSeason = ->
    return '' unless $scope.current_stat?
    return $scope.current_stat.season if $scope.current_stat.season?
    $scope.last_season

  $scope.statYearSelected = ->
    if $scope.current_stat != $scope.all_stats then 'active' else ''

  $scope.notStatYearSelected = ->
    if $scope.current_stat == $scope.all_stats then 'active' else ''

  $scope.firstFixture = (first) ->
    if first? then 'is-active' else ''

  $scope.addressComponents = (venue) ->
    return '' unless venue?
    ary = []
    ary << venue.address2
    ary << venue.address3
    ary << venue.suburb + ' ' + venue.state + ', ' + venue.zipcode if venue.suburb? or venue.state? or venue.zipcode?
    concat = ary.join(', ')
    concat = if concat.length > 0 or venue.address1 then (concat + ' - ') else ''

  $scope.toggleShare = ->
    $scope.share_visible = !$scope.share_visible

  $scope.toggleShare2 = ->
    $scope.share_visible2 = !$scope.share_visible2

  $scope.toggleShare3 = ->
    $scope.share_visible3 = !$scope.share_visible3

  $scope.gameUrl = (game, user) ->
    if user.id?
      $location.url("/users/" + user.id + "/games/" + game.id + "/played")
    else
      $location.url("/games/" + game.id + "/played")

  include = (ary, obj) ->
    return true for a in ary when a == obj
    false

  $scope.highlightTeamInStandings = (standing) ->
    return 'standings-my-team' if $scope.user? and $scope.user.club_id == standing.club_id and
      ($scope.user.team_id == standing.team_id or include($scope.user.previous_teams, standing.id))
    ''

  $scope.showFormation = (result) ->
    return '' unless result? and result.formation?
    return '3-5-2 W' if result.formation is '3-5-2 Wingbacks'
    return '4-4-2 D' if result.formation is '4-4-2 Diamond'
    return result.formation

#  $scope.didWin = (game,reversed) ->
#    return '?' unless game.home_team_score? and game.away_team_score?
#    if (game.home_or_away is 'home') isnt reversed
#      if game.home_team_score > game.away_team_score
#        'W'
#      else if game.home_team_score == game.away_team_score
#        'D'
#      else 'L'
#    else
#      if game.home_team_score > game.away_team_score
#        'L'
#      else if game.home_team_score == game.away_team_score
#        'D'
#      else 'W'

ngApp.controller('DashboardCtrl', ['$scope', '$rootScope', '$routeParams', '$location', '$window', '$sce', '$modal',
                                   'screenSize', 'sharedServices', 'API', 'FileUploader', DashboardCtrl])
ngApp.controller('MapModalInstanceCtrl', ['$scope', '$modalInstance', '$sce', 'map', 'game', 'unknown_address', MapModalInstanceCtrl])
ngApp.controller('GameDataModalInstanceCtrl', ['$scope', '$modalInstance', '$location', '$routeParams', '$filter', 'sharedServices', 'data', 'user', GameDataModalInstanceCtrl])

ngApp.controller('AwardModalCtrl', ['$scope', '$modalInstance', 'award', 'user', AwardModalCtrl])
ngApp.controller('MediaModalCtrl', ['$scope', '$modalInstance', 'media', 'user', MediaModalCtrl])