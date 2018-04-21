
# See https://github.com/angular-ui/bootstrap/issues/2017 - issue with bluring form elements in modals
# See also https://github.com/angular/angular.js/pull/11212
ngApp.directive 'stopEvent', ->
  {
    restrict: 'A',
    link: (scope, element, attr) ->
      element.on attr.stopEvent, (e) ->
        e.stopPropagation()
  }

@transformUser = (user) ->
  try
    user = angular.fromJson(user)
  catch SyntaxError
    return {}

  user.dob = new Date(user.dob) if user.dob?
  #user.player_profile.player_no = parseInt(user.player_profile.player_no) if user.player_profile? and user.player_profile.player_no?
  #user.position_ids = (pos.id for pos in user.positions)
  user.position_id = if user? and user.positions? and user.positions.length > 0 then user.positions[0].id else ''
  user.avatar.url = '/img/avatar.gif' if user? and user.avatar? and not user.avatar.url?
  user

ngApp.factory('API', [
  '$resource', ($resource) ->
    {
    Positions:      $resource(apiEndpoint + '/positions/:id.json', {id: '@id'},
                      {
                        'query':          { method: 'GET', isArray: true },
                        'update':         { method: 'PUT' } # TODO: Shouldn't be required, blocked at backend?
                      }),
    Users:          $resource(apiEndpoint + '/users/:id.json', {id: '@id'},
                      {
                        'get':            { method: 'GET', transformResponse: transformUser },
                        'current_user':   { method: 'GET', transformResponse: transformUser },
                        'update':         { method: 'PUT', transformResponse: transformUser },
                        'update_club':    { method: 'POST', url: '/users/update_club' },
                        'update_team':    { method: 'POST', url: '/users/update_team' }
                        'player_equipments':      { method: 'GET', isArray: true, url: '/users/:id/player_equipments.json' },
                        'prior_games':    { method: 'GET', isArray: true, url: '/users/:id/prior_games.json' },
                        'team_games':     { method: 'GET', isArray: true, url: '/users/:id/team_games.json' },
                        'with_games':     { method: 'GET', url: '/users/:user_id/teams/:id.json?with_games=1' },
                        'season_stats':   { method: 'GET', isArray: false, url: '/users/:id/season_stats.json' },
                        'playing_career': { method: 'GET', isArray: false, url: '/users/:id/playing_career.json' },
                      }),

    Associations:   $resource(apiEndpoint + '/associations/:id.json', {id: '@id'},
                      {
                        'update':         { method: 'PUT' },
                        'divisions':      { method: 'GET', isArray: true, url: '/associations/:id/divisions.json' },
                      }),
    Divisions:      $resource(apiEndpoint + '/divisions/:id.json', {id: '@id'},
                      {
                        'update':         { method: 'PUT' },
                        'teams':          { method: 'GET', isArray: true, url: '/divisions/:id/teams.json' },
                      }),

    Clubs:          $resource(apiEndpoint + '/clubs/:id.json', {id: '@id'},
                      {
                        'update':         { method: 'PUT' },
                        'find_by_letter': { method: 'GET', isArray: true },
                        'teams':          { method: 'GET', isArray: true, url: '/clubs/:id/teams.json' },
                      }),

    Teams:          $resource(apiEndpoint + '/teams/:id.json', {id: '@id'},
                      {
                        'update':             { method: 'PUT' },
                        'with_games':         { method: 'GET', url: '/teams/:id.json?with_games=1'},
                        'previous_team_games':{ method: 'GET', isArray: true, url: '/teams/previous_games'},
                        #'last_results':       { method: 'GET', isArray: true, url: '/teams/:id/last_results.json' },
                        'previous_meetings':  { method: 'GET', url: '/teams/:id/previous_meetings.json'}
                      }),

    Games:          $resource(apiEndpoint + '/games/:id.json', {id: '@id'},
                      {
                        'update':           { method: 'PUT' },
                        'player_results':   { method: 'GET', isArray: true, url: '/games/:id/player_results.json'}
                        'weather_forecast': { method: 'GET', url: '/games/:id/weather_forecast.json'}
                      }),

    Leagues:        $resource(apiEndpoint + '/leagues/:id.json', {id: '@id'},
                      {
                        'update':           { method: 'PUT' },
                        'standings':        { method: 'GET', url: '/leagues/:id/standings.json'}
                      }),

    PlayerResults:  $resource(apiEndpoint + '/player_results/:id.json', {id: '@id'},
                      {
                        'from_game':      { method: 'GET', url: '/games/:game_id/player_results/from_game.json'}
                        'from_games':     { method: 'GET', isArray: true, url: '/player_results/from_games.json'}
                        'save':           { method: 'POST', url: '/games/:game_id/player_results.json' }
                        'update':         { method: 'PUT' },
                      }),

    PlayerProfiles: $resource(apiEndpoint + '/player_profiles/:id.json',  {id: '@id'}, {'update': { method: 'PUT' } }),
    Brands:         $resource(apiEndpoint + '/brands/:id.json',           {id: '@id'}, {'update': { method: 'PUT' } }),
    Equipment:      $resource(apiEndpoint + '/equipment/:id.json',        {id: '@id'}, {'update': { method: 'PUT' } }),
    PlayerEquipment: $resource(apiEndpoint + '/player_equipment/:id.json', {id: '@id'},
                      {
                        'save': { method: 'POST', url: '/users/:id/player_equipment.json'}
                        'update': { method: 'PUT' }
                      }),
    Articles:       $resource(apiEndpoint + '/articles/:id.json',         {id: '@id'}, {'update': { method: 'PUT' } }),
    }
])



## Success and error handlers ##########################################################################################
@success = () ->
  #angular.element(document.body.querySelector('#warning')).hide()



@RedirectCtrl = ($scope, $rootScope, $location, API) ->
  # $rootScope.current_user = API.Users.current_user (user) ->
  user = {id: 1074}
  if user.id?
    if $location.path().indexOf('/dashboard') == 0
      $location.url('/users/' + user.id + '/dashboard')
    if $location.path().indexOf('/schedule') == 0
      $location.url('/users/' + user.id + '/schedule')
    if $location.path().indexOf('/standings') == 0
      $location.url('/users/' + user.id + '/standings')
    if $location.path().indexOf('/player_profiles/personal') == 0
      $location.url('/users/' + user.id + '/player_profiles/personal')

  # , ->
  #   if $location.path().indexOf('/loading') == 0
  #     window.location.pathname = '/user_sessions/new'


@WelcomeCtrl = ($scope, $rootScope, $location, API) ->
  $rootScope.current_user = API.Users.current_user (user) ->
    if user.id?
      $location.url('/users/' + user.id + '/dashboard')
    else
      window.location.pathname = '/user_sessions/new'

  , ->
    if $location.path().indexOf('/loading') == 0
      window.location.pathname = '/user_sessions/new'

ngApp.controller('RedirectCtrl', ['$scope', '$rootScope', '$location', 'API', RedirectCtrl])
ngApp.controller('WelcomeCtrl', ['$scope', '$rootScope', '$location', 'API', WelcomeCtrl])


# Add controllers to ngApp module ######################################################################################


