# Teams controllers ####################################################################################################

@teamError = () ->
  $('#warning').html("Error whilst loading or saving team details")
  $('#warning').show

@TeamListCtrl = ($scope, $rootScope, $routeParams, $location, API) ->

  #$scope.navCollapsed = window.innerWidth <= 990

  $scope.user = $rootScope.user
  $scope.club = $rootScope.club
  $scope.association = $rootScope.association
  $scope.clubVisible = angular.isDefined($rootScope.club)
  $scope.divisions = [] #if $scope.clubVisible then API.Associations.divisions({id: $scope.association.id}, success, teamError) else []
  $scope.division = {}
  $scope.team = {}
  $scope.teamSelected = false

  $scope.selectDivision = (division) ->
    $scope.division = division
    $scope.division.teams = API.Divisions.teams({id: $scope.division.id}, success, teamError)

  $scope.clubLogo = (club) ->
    return '/img/no-club-logo.gif' unless club? and club.logo? and club.logo.logo? and club.logo.logo.url?
    club.logo.logo.url

  $scope.selectTeam = (team) ->
    $scope.team = team
    $scope.teamSelected = true

  $scope.confirmTeam = (team) ->
    $rootScope.team = $scope.team = team
    $location.url('/teams/confirm')

@TeamCtrl = ($scope, $rootScope, $routeParams, $location, API) ->

  #$scope.navCollapsed = window.innerWidth <= 990

  $scope.club = $rootScope.club || {}
  $scope.team = $rootScope.team || {}
  $scope.teamVisible = angular.isDefined($rootScope.team)
  $scope.user = {}

  # Refresh the team, with player details
  API.Teams.get {id: $scope.team.id}, (team) ->
    $scope.team = team

  redirectToShow = (result) ->
    $location.url('/teams/' + result.id)

  redirectToList = (result) ->
    $location.url('/teams/')

  $rootScope.current_user = API.Users.current_user { id:$routeParams.user_id }, (user) ->

    # If the user is not logged in, force them to do so now
    unless user.id?
      $rootScope.user_logged_out = true
      window.location.pathname = '/user_sessions/new'
      return

    if $routeParams.id
      $scope.team = API.Teams.get { id:$routeParams.id }, success, teamError

  $scope.confirmTeam = () ->
    API.Users.update_team({team_id: $scope.team.id}, () ->
      success()
      $location.url('/users/' + $rootScope.current_user.id + '/dashboard')
    teamError)

  $scope.clubLogo = (club) ->
    return '/img/no-club-logo.gif' unless club? and club.logo? and club.logo.logo? and club.logo.logo.url?
    club.logo.logo.url

  $scope.gameUrl = (game, user) ->
    if user?
      $location.url("/users/" + user.id + "/games/" + game.id + "/played")
    else
      $location.url("/games/" + game.id + "/played")

  $scope.create = (team) -> API.Team.save(team, redirectToShow, teamError)
  $scope.update = (team) -> team.$update(redirectToShow, teamError)
  $scope.delete = (team) ->
    if confirm 'Delete this team?'
      team.$remove(redirectToList, teamError)

ngApp.controller('TeamListCtrl',          ['$scope', '$rootScope', '$routeParams', '$location', 'API', TeamListCtrl])
ngApp.controller('TeamCtrl',              ['$scope', '$rootScope', '$routeParams', '$location', 'API', TeamCtrl])
