# User controllers #####################################################################################################

@userError = (e) ->
  if e.data.error
    $('#warning').html(e.data.error)
  else
    $('#warning').html("Error whilst loading or saving user details")
  $('#warning').show

@UserListCtrl = ($scope, $routeParams, $location, API) ->
  $scope.users = API.Users.query(success, userError)

@UserCtrl = ($scope, $routeParams, $location, API) ->
  redirectToShow = (result) ->
    $location.url('/users/' + result.id)

  redirectToFindClubs = (result) ->
    $location.url('/clubs/find')

  redirectToList = (result) ->
    $location.url('/users/')

  $scope.user = {}
  if $routeParams.id
    $scope.user = API.Users.get { id:$routeParams.id }, success, userError

  $scope.create = (user) -> API.Users.save(user, redirectToFindClubs, userError)
  $scope.update = (user) -> user.$update(redirectToShow, userError)
  $scope.delete = (user) ->
    if confirm 'Delete this user?'
      user.$remove(redirectToList, userError)


ngApp.controller('UserListCtrl',          ['$scope', '$routeParams', '$location', 'API', UserListCtrl])
ngApp.controller('UserCtrl',              ['$scope', '$routeParams', '$location', 'API', UserCtrl])
