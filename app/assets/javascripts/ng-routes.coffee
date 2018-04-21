
# Angular.js Routing ###################################################################################################
ngApp.config(['$routeProvider', ($routeProvider) ->

  $routeProvider.when '/loading',           { templateUrl: 'static/loading.html'}
  $routeProvider.when '/privacy',           { templateUrl: 'static/privacy.html'}
  $routeProvider.when '/tos',               { templateUrl: 'static/tos.html'}
  $routeProvider.when '/join',              { templateUrl: 'static/join.html'}
  $routeProvider.when '/join/current_team', { templateUrl: 'static/join.html'}
  $routeProvider.when '/join/registered',   { templateUrl: 'static/registered.html'}

  $routeProvider.when '/clubs/',            { templateUrl: 'clubs/index.html' }
  $routeProvider.when '/clubs/new',         { templateUrl: 'clubs/new.html', }
  $routeProvider.when '/clubs/find',        { templateUrl: 'clubs/find.html' }
  $routeProvider.when '/clubs/:id',         { templateUrl: 'clubs/show.html' }
  $routeProvider.when '/clubs/:id/edit',    { templateUrl: 'clubs/edit.html' }
  $routeProvider.when '/clubs/:id/logo',    { templateUrl: 'clubs/logo.html' }

  $routeProvider.when '/associations/:id/logo',    { templateUrl: 'assoc/logo.html' }

  $routeProvider.when '/teams/:team_id/schedule',       { templateUrl: 'dashboard/schedule.html' }
  $routeProvider.when '/teams/select',                  { templateUrl: 'teams/select.html' }
  $routeProvider.when '/teams/confirm',                 { templateUrl: 'teams/confirm.html' }

  $routeProvider.when '/dashboard',                     { templateUrl: 'redirect.html' }
  $routeProvider.when '/schedule',                      { templateUrl: 'redirect.html' }
  $routeProvider.when '/standings',                     { templateUrl: 'redirect.html' }

  $routeProvider.when '/users/:user_id/dashboard',      { templateUrl: 'dashboard/dashboard.html' }
  $routeProvider.when '/users/:user_id/schedule',        { templateUrl: 'dashboard/schedule.html' }
  $routeProvider.when '/users/:user_id/fixture-more',   { templateUrl: 'dashboard/fixture-more.html' }
  $routeProvider.when '/users/:user_id/match-details',  { templateUrl: 'dashboard/match-details.html' }
  $routeProvider.when '/users/:user_id/standings',      { templateUrl: 'dashboard/standings.html' }

  $routeProvider.when '/users/:user_id/games/:id',              { templateUrl: 'games/show.html' }
  $routeProvider.when '/users/:user_id/games/:id/played',       { templateUrl: 'games/show-played.html' }
  $routeProvider.when '/users/:user_id/games/:id/played/edit',  { templateUrl: 'games/show-played.html' }
  $routeProvider.when '/games/:id/played',              { templateUrl: 'games/show-played.html' }
  $routeProvider.when '/games/:id/played/edit',         { templateUrl: 'games/show-played.html' }


  $routeProvider.when '/users/:user_id/player_profiles/',                             { templateUrl: 'player_profiles/index.html',  controller: PlayerProfileListCtrl }
  $routeProvider.when '/users/:user_id/player_profiles/personal',                     { templateUrl: 'player_profiles/personal.html' }
  $routeProvider.when '/users/:user_id/player_profiles/profile',                      { templateUrl: 'player_profiles/profile.html' }
  $routeProvider.when '/users/:user_id/player_profiles/gear',                         { templateUrl: 'player_profiles/gear.html' }
  $routeProvider.when '/users/:user_id/player_profiles/gear/add/:kind',               { templateUrl: 'player_profiles/gear.html' }
  $routeProvider.when '/users/:user_id/player_profiles/gear/add/:kind/brand/:brand',  { templateUrl: 'player_profiles/gear.html' }
  $routeProvider.when '/users/:user_id/player_profiles/gear/add/:kind/brand/:brand/:name', { templateUrl: 'player_profiles/gear.html' }
  #$routeProvider.when '/users/:user_id/player_profiles/model/:kind/:brand',           { templateUrl: 'player_profiles/model.html' }
  #$routeProvider.when '/users/:user_id/player_profiles/features/:kind/:brand/:model', { templateUrl: 'player_profiles/features.html' }
  #$routeProvider.when '/users/:user_id/player_profiles/account',                      { templateUrl: 'player_profiles/account.html' }
  $routeProvider.when '/users/:user_id/player_profiles/new',                          { templateUrl: 'player_profiles/new.html',    controller: PlayerProfileCtrl }
  $routeProvider.when '/users/:user_id/player_profiles/:id',                          { templateUrl: 'player_profiles/show.html',   controller: PlayerProfileCtrl }
  $routeProvider.when '/users/:user_id/player_profiles/:id/edit',                     { templateUrl: 'player_profiles/edit.html',   controller: PlayerProfileCtrl }

  $routeProvider.when '/users/:user_id/avatar',                                       { templateUrl: 'users/avatar.html' }

  $routeProvider.when '/player_profiles/personal',                                    { templateUrl: 'redirect.html' }

  $routeProvider.when '/health-and-wellbeing/',            { templateUrl: 'articles/health-and-wellbeing.html' }
  $routeProvider.when '/training-and-performance/',            { templateUrl: 'articles/training-and-performance.html' }


  $routeProvider.otherwise {redirectTo: '/loading'}

  # html5 mode gets rid of hash-bang paths (e.g. #!/incomes/123 )
  #$locationProvider.html5Mode(true);
])

