# Clubs controllers ####################################################################################################

@clubError = () ->
  $('#warning').html("Error whilst loading or saving club details")
  $('#warning').show()

@ClubListCtrl = ($scope, $rootScope, $routeParams, $location, API) ->

  #$scope.navCollapsed = window.innerWidth <= 990

  ### Share animation handling ###
  $scope.share_visible = false
  $scope.share_visible2 = false

  $scope.toggleShare = ->
    $scope.share_visible = !$scope.share_visible

  $scope.toggleShare2 = ->
    $scope.share_visible2 = !$scope.share_visible2

  API.Users.current_user { id:$routeParams.user_id }, (user) ->
    $rootScope.user = user
    $rootScope.current_user = user
  , clubError

  showClubs = ->
    $scope.showClubs = true
    success()

  $scope.letters = (String.fromCharCode(letter) for letter in ['A'.charCodeAt(0)..'Z'.charCodeAt(0)])
  $scope.letter = ''
  $scope.clubs = []
  $scope.club = false
  $scope.showClubs = false
  $scope.clubSelected = false

  $scope.chooseLetter = (letter) ->
    $scope.letter = letter
    $scope.clubs = API.Clubs.find_by_letter(letter: letter, showClubs, clubError)

  $scope.selectClub = (club) ->
    $scope.club = club
    $scope.clubSelected = true

  $scope.confirmClub = (club) ->
    API.Users.update_club(club_id: club.id, () ->
      $rootScope.club = API.Clubs.get({id: club.id, year: new Date().getFullYear()}, ->
        $location.url('/teams/select')
      , clubError)
      #$rootScope.association = API.Associations.get({id: $scope.club.association_id}, () ->
      #associationError)
      success()
    userError)
#ClubListCtrl.$inject = ["$scope", "$rootScope", "$routeParams", "$location", "API"];

### Modal controller - team list ###
@TeamListModalInstanceCtrl = ($scope, $modalInstance, $location, teams, club) ->
  $scope.teams = teams
  $scope.club = club

  $scope.teamUrl = (team) ->
    if $scope.current_user.team_id == team.id
      $location.url('/users/' + $scope.current_user.id + '/schedule')
    else
      $location.url('/teams/' + team.id + '/schedule')

  $scope.selectTeam = (team) ->
    $modalInstance.dismiss('cancel')
    $scope.teamUrl(team)

  $scope.enhanceLeagueName = (team) ->
    return '' unless team? and team.league?
    team.league.name + (if team.name != team.league.name then ' [' + team.name + ']' else '')

  $scope.cancel = ->
    $modalInstance.dismiss('cancel')


@ClubCtrl = ($scope, $rootScope, $routeParams, $location, $window, $sce, $filter, $modal, sharedServices, FileUploader, API) ->

  $scope.current_year = new Date().getFullYear()

  # Used to display the Facebook widget
  $rootScope.facebookAppId = 1634238556839708

  $scope.map_shown = false

  $scope.back_button = switch $scope.page
    when 'dashboard' then false
    else true

  $scope.backClicked = ->
    $window.history.back();

  API.Users.current_user { id:$routeParams.user_id }, (user) ->

    # If the user is not logged in, force them to do so now
    unless user.id?
      $rootScope.user_logged_out = true
      window.location.pathname = '/user_sessions/new'
      return

    $scope.user = user
    $rootScope.current_user = user

    $scope.club = {}
    if $routeParams.id
      API.Clubs.get { id:$routeParams.id, year: new Date().getFullYear() }, (club) ->
        $scope.club = club
        $scope.map.center.latitude = club.location.latitude if club? and club.location? and club.location.latitude?
        $scope.map.center.longitude = club.location.longitude if club? and club.location? and club.location.longitude?
        $scope.map.marker.latitude = club.location.latitude if club? and club.location? and club.location.latitude?
        $scope.map.marker.longitude = club.location.longitude if club? and club.location? and club.location.longitude?
        $scope.map_shown = true
        $scope.teams = club.teams.slice(0, 8)
      , clubError

  , clubError

  redirectToShow = (result) ->
    $location.url('/clubs/' + result.id)

  redirectToList = (result) ->
    $location.url('/clubs/')

  $scope.page = 'schedule'
  $scope.page_title = 'Club Details'

  # Shared services
  $scope.toggleButtonClass = (navCollapsed)     -> sharedServices.toggleButtonClass(navCollapsed)
  $scope.toggleSidebarClass = (navCollapsed)    -> sharedServices.toggleSidebarClass(navCollapsed)

  $scope.map = { center: {latitude: 0, longitude: 0}, zoom: 16, marker: {} }

  $scope.trustedDescription = (club, truncate) ->
    return '' unless club?
    if truncate
      # TODO: This doesn't work as we can't truncate the special JavaScript object type created
      $filter('characters')($sce.trustAsHtml(club.description), 160)
    else
      $sce.trustAsHtml(club.description)

  $scope.fullDescription = false

  $scope.showFullDescription = ->
    $scope.fullDescription = true

  $scope.create = (club) -> API.Clubs.save(club, redirectToShow, clubError)
  $scope.update = (club) -> club.$update(redirectToShow, clubError)
  $scope.delete = (club) ->
    if confirm 'Delete this club?'
      club.$remove(redirectToList, clubError)

  $scope.clubLogo = (club) ->
    return '/img/no-club-logo.gif' unless club? and club.logo? and club.logo.logo? and club.logo.logo.url?
    club.logo.logo.url

  ### Uploader for clubs ###
  csrf_token = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
  $scope.uploader = new FileUploader({
    url: '/clubs/upload',
    autoUpload: true,
    headers : { 'X-CSRF-TOKEN': csrf_token },
    onCompleteItem: (item, response, status, headers) ->
      $scope.club = response

    onBeforeUploadItem: (item) ->
      item.formData.push {id: $scope.club.id}

    onErrorItem: (item, response, status, headers) ->
      $('#warning').html("Error whilst uploading avatar")
      $('#warning').addClass('alert')
      $('#warning').addClass('alert-warning')
      $('#warning').show
  })

  $scope.teamUrl = (team) ->
    if $scope.current_user.team_id == team.id
      $location.url('/users/' + $scope.current_user.id + '/schedule')
    else
      $location.url('/teams/' + team.id + '/schedule')

  $scope.showAllTeams = ->
    modalInstance = $modal.open {
      templateUrl: 'clubs/_all-teams.html',
      controller: 'TeamListModalInstanceCtrl',
      resolve: {
        teams: ->
          $scope.club.teams
        club: ->
          $scope.club
      }
    }

  $scope.facebookPageUrl = (club) ->
    return "" unless club? and club.facebook?
    $sce.trustAsUrl("https://www.facebook.com/" + club.facebook)

  $scope.searchAddress = (club) ->
    return '' unless club? and club.location?
    # Embedded is .../embed/v1/place/?q=..., key is ...&key=googleApi...
    $sce.trustAsUrl('https://www.google.com/maps/?q=' + encodeURI(club.location.full_address)).toString()

  $scope.enhanceLeagueName = (team) ->
    team.league.name + (if team.name != team.league.name then ' [' + team.name + ']' else '')

#ClubCtrl.$inject = ["$scope", "$routeParams", "$location", "API"];

ngApp.controller('ClubListCtrl',          ['$scope', '$rootScope', '$routeParams', '$location', 'API', ClubListCtrl])
ngApp.controller('ClubCtrl',              ['$scope', '$rootScope', '$routeParams', '$location', '$window', '$sce', '$filter',
                                           '$modal', 'sharedServices', 'FileUploader', 'API', ClubCtrl])
ngApp.controller('TeamListModalInstanceCtrl', ['$scope', '$modalInstance', '$location', 'teams', 'club', TeamListModalInstanceCtrl])
