# Initialize the angular module, 'champtracker' app and dependencies ###################################################
@ngApp = angular.module('champtracker', ['ngRoute', 'ngResource', 'ngSanitize', 'ngAnimate', 'ngTouch', 'ui.bootstrap',
  'angularFileUpload', 'easypiechart',
  'angular.vertilize', 'uiGmapgoogle-maps', 'truncate', 'countrySelect',
  'angulartics', 'angulartics.google.analytics', 'templates', 'matchMedia', 'ezfb']) #, 'imgEditor.directives', 'angularSlideables']) # 'checklist-model',
ngApp.run ['$rootScope', ($rootScope) ->
]

ngApp.config(['$sceDelegateProvider', ($sceDelegateProvider) ->
  $sceDelegateProvider.resourceUrlWhitelist(['self', 'https://www.google.com/maps/embed/**', 'https://app.champtracker.com/**',
    'http://localhost:3000/**', 'https://connect.facebook.net/**', 'https://www.facebook.com/**', 'https://twitter.com/**',
    'https://www.youtube.com/embed/**'])
])

ngApp.config(['ezfbProvider', (ezfbProvider) ->
  ezfbProvider.setInitParams({appId: '1634238556839708'})
])

# Template cache for modal dialogs to be pre-loaded on mobile devices
#ngApp.run ['$templateCache', '$http', '$timeout', ($templateCache, $http, $timeout) ->
#  $timeout( ->
#    $http.get 'dashboard/_game-data.html', { cache: true}, (tpl) ->
#      $templateCache.put '/assets/dashboard/_game-data.html', tpl
#  , 5000)
#]

# TODO: Disabled due to minification issue
#ngApp.config ($analyticsProvider) ->
#  $analyticsProvider.firstPageview(true)  # Records pages that don't use $state or $route
#  $analyticsProvider.withAutoBase(true)   # Records full path

window.mode = window.location.hostname
if window.mode.toLowerCase().indexOf('champtracker.com') >= 0
  @apiEndpoint = 'https://app.champtracker.com'
  @googleApi = 'AIzaSyCqS9w5B8-e3GNBTIAzoP1WWivQev_UMXU'
else if window.mode is 'ct.greenshoresdigital.com'
  @apiEndpoint = 'http://ct.greenshoresdigital.com'
  @googleApi = 'AIzaSyDoNFNCUWv6-1XkOGJOHyEZd2aLU-hgqJ4'
else if window.mode isnt 'localhost'
  window.location = 'http://localhost:3000'
else
  @apiEndpoint = 'http://localhost:' + window.location.port
  @googleApi = 'AIzaSyDoNFNCUWv6-1XkOGJOHyEZd2aLU-hgqJ4'

ngApp.config(['uiGmapGoogleMapApiProvider', (uiGmapGoogleMapApiProvider) ->
  uiGmapGoogleMapApiProvider.configure {
    key: googleApi
    v: '3.17',
    libraries: 'weather,geometry,visualization'
  }
])

ngApp.factory('sharedServices', [() ->

  shared = {
    # Navigation ##################################################################################

    toggleButtonClass: (navCollapsed) ->
      if navCollapsed then 'collapsed' else 'in'

    toggleSidebarClass: (navCollapsed) ->
      return 'in' if window.innerWidth >= 990
      !navCollapsed && 'in'

    # Global ######

    currentYear: ->
      new Date().getFullYear()

    # Roles #######################################################################################

    isGoalkeeper: ($scope) ->
      return false unless $scope.user? and $scope.user.active_sport_profile?
      return $scope.user.active_sport_profile.position == 'Goalkeeper'

    isCoach: ($scope) ->
      return false unless $scope.user? and $scope.user.active_sport_profile?
      return $scope.user.active_sport_profile.position == 'Coach' or
          $scope.user.active_sport_profile.position == 'Assistant Coach'

    isRep: ($scope, rep) ->
      return false unless $scope.user?
      $scope.user.reputation_score >= rep

    # Back button #################################################################################

    backClicked: ($window) ->
      $window.history.back()

    # Award Modal
    openAward: ($scope, $modal, award, user) ->
      modalInstance = $modal.open {
        templateUrl: 'dashboard/_award.html',
        controller: 'AwardModalCtrl',
        resolve: {
          award: ->
            award
          user: ->
            user
        }
      }

    # Media Modal
    openMedia: ($scope, $modal, media, user) ->
      modalInstance = $modal.open {
        templateUrl: 'dashboard/_media_section.html',
        controller: 'MediaModalCtrl',
        resolve: {
          media: ->
            media
          user: ->
            user
        }
      }


    # Map Modal ###################################################################################

    openMap: ($scope, $modal, game) ->
      modalInstance = $modal.open {
        templateUrl: 'dashboard/_game-map.html',
        controller: 'MapModalInstanceCtrl',
        resolve: {
          map: ->
            $scope.map
          game: ->
            game
          unknown_address: ->
            $scope.unknown_address
        }
      }

    # Open game data modals #######################################################################

    openGameData2: ($scope, $modal, $rootScope, API) ->
      $('body').addClass('modal-open')
      modalInstance = $modal.open {
        templateUrl: 'dashboard/_game-data.html',
        controller: 'GameDataModalInstanceCtrl',
        resolve: {
          data: ->
            data = angular.copy($scope.game_data)
            data.home_score = null
            data.away_score = null
            if data.game_links?
              photo_links = (link.url for link in data.game_links when link.kind == 'photos')
              data.photo_link = photo_links[0] if photo_links.length > 0
              video_links = (link for link in data.game_links when link.kind.startsWith('video'))
              if video_links.length > 0
                data.video_link = video_links[0].url
                data.video_link = ("https://www.youtube.com/watch?v=" + data.video_link) if video_links[0].kind == 'video_youtube'
                data.video_link = ("https://vimeo.com/channels/username/" + data.video_link) if video_links[0].kind == 'video_vimeo'
                data.video_link = ("https://www.facebook.com/" + data.video_link) if video_links[0].kind == 'video_facebook'
            data.minutes_played = 90 if data.minutes_played == 0
            data.goals = null if data.goals == 0
            if data.specialized?
              data.specialized.penalty_saves = null if data.specialized.penalty_saves == 0
              data.specialized.assists = null if data.specialized.assists == 0
              data.specialized.yellow_cards = null if data.specialized.yellow_cards == 0
              data.specialized.red_cards = null if data.specialized.red_cards == 0
            data
          user: ->
            $rootScope.current_user
        }
      }

      modalInstance.result.then((data) ->
        $scope.game = data.game
        game = data.game
        $scope.game.home_team_score = data.home_score if data.home_score?
        $scope.game.away_team_score = data.away_score if data.away_score?
        data.game = null
        $scope.game_data = data
        data.goals = 0 unless data.goals?
        $scope.game_data.sport = 'soccer' unless $scope.game_data.sport?
        if data.id
          data.$update({game_id: data.game_id}, (result) ->
            $scope.game.home_team_score = game.home_team_score
            $scope.game.away_team_score = game.away_team_score
            $scope.game.state = 'final_score'
            $scope.game_data = result
            $scope.player_results[i] = result for pr, i in $scope.player_results when pr.id == result.id
          , gamesError)
        else
          data.$save({game_id: data.game_id}, ->
            $scope.addOrEditStats = 'Edit stats'
            $scope.addOrEditClass = 'btn-default'
            $scope.game_data = result
            $scope.player_results[i] = result for pr, i in $scope.player_results when pr.id == result.id
            success
          , gamesError)

        # Re-retrieve the screen data with the latest updates
        $scope.retrievePlayerResults()
      , ->
      )

    openGameData: ($scope, $modal, $rootScope, $routeParams, $location, API) ->
      $('body').addClass('modal-open')
      modalInstance = $modal.open {
        templateUrl: 'dashboard/_game-data.html',
        controller: 'GameDataModalInstanceCtrl',
        resolve: {
          data: ->
            data = angular.copy($scope.game_data)
            data.home_score = null
            data.away_score = null
            if data.game_links?
              photo_links = (link.url for link in data.game_links when link.kind == 'photos')
              data.photo_link = photo_links[0] if photo_links.length > 0
              video_links = (link for link in data.game_links when link.kind.startsWith('video'))
              if video_links.length > 0
                data.video_link = video_links[0].url
                data.video_link = ("https://www.youtube.com/watch?v=" + data.video_link) if video_links[0].kind == 'video_youtube'
                data.video_link = ("https://vimeo.com/channels/username/" + data.video_link) if video_links[0].kind == 'video_vimeo'
                data.video_link = ("https://www.facebook.com/" + data.video_link) if video_links[0].kind == 'video_facebook'
            data.minutes_played = 90 if data.minutes_played == 0
            data.goals = null if data.goals == 0
            if data.specialized?
              data.specialized.penalty_saves = null if data.specialized.penalty_saves == 0
              data.specialized.assists = null if data.specialized.assists == 0
              data.specialized.yellow_cards = null if data.specialized.yellow_cards == 0
              data.specialized.red_cards = null if data.specialized.red_cards == 0
            data
          user: ->
            $rootScope.current_user
        }
      }

      modalInstance.result.then((data) ->
        game = data.game
        game.home_team_score = data.home_score if data.home_score?
        game.away_team_score = data.away_score if data.away_score?
        data.game = null
        $scope.game_data = data
        data.goals = 0 unless data.goals?
        $scope.game_data.sport = 'soccer' unless $scope.game_data.sport?
        if data.id
          data.$update({game_id: data.game_id}, ->

            current_game = (g for g in $scope.prior_games when g.id == data.game_id)
            current_game[0].home_team_score = game.home_team_score
            current_game[0].away_team_score = game.away_team_score
            current_game[0].state = 'final_score'

            if $location.url().split('/')[3] is 'schedule'
              game_ids = (g.id for g in $scope.prior_games)
              $scope.retrieveAllPlayerResults(game_ids)

            # Re-retrieve the season stats with the latest updates
            API.Users.season_stats { id: $routeParams.user_id }, (stats) ->
              $scope.updateSeasonStats(stats)
            , dashboardError

          , dashboardError)
        else
          data.$save({game_id: data.game_id}, ->
            $scope.addOrEditStats = 'Edit stats'
            $scope.addOrEditClass = 'btn-default'
            data.btn_text = 'Edit stats'
            data.btn_class = 'btn-default'

            if $location.url().split('/')[3] is 'dashboard'
              $scope.user.team.past_games[0].home_team_score = game.home_team_score
              $scope.user.team.past_games[0].away_team_score = game.away_team_score
              $scope.user.team.past_games[0].state = 'final_score'

            if $location.url().split('/')[3] is 'schedule'

              current_game = (g for g in $scope.prior_games when g.id == data.game_id)
              current_game[0].home_team_score = game.home_team_score
              current_game[0].away_team_score = game.away_team_score
              current_game[0].state = 'final_score'

              game_ids = (g.id for g in $scope.prior_games)
              $scope.retrieveAllPlayerResults(game_ids)

            # Re-retrieve the season stats with the latest updates
            API.Users.season_stats { id: $routeParams.user_id }, (stats) ->
              $scope.updateSeasonStats(stats)
            , dashboardError

            success
          , dashboardError)
      , ->
      )

    clubLogo: ($scope, team) ->
      return '/img/no-club-logo.gif' unless team? and team.club? and team.club.logo? and team.club.logo.url?
      team.club.logo.url

    enhanceClubName: ($scope, team) ->
      return '' unless team?
      if team.league_count > 1
        team.club.name + ' [' + team.name + ']'
      else
        team.club.name

    homeWinner: ($scope, game) ->
      return '' unless game?
      if game.home_team_score > game.away_team_score then 'winner' else ''

    awayWinner: ($scope, game) ->
      return '' unless game?
      if game.home_team_score < game.away_team_score then 'winner' else ''

    containsVideo: ($scope, game_links) ->
      return false unless game_links?
      videos = (link for link in game_links when link.kind.startsWith('video'))
      videos.length > 0

    containsImage: ($scope, game_links) ->
      return false unless game_links?
      images = (link for link in game_links when not link.kind.startsWith('video'))
      images.length > 0

    selectFormation: ($scope, formation) ->
      $scope.data.formation = formation

  }
  shared
])
