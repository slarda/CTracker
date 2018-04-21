# Association controllers ##############################################################################################

@associationError = () ->
  $('#warning').html("Error whilst loading or saving association details")
  $('#warning').show

@AssociationListCtrl = ($scope, $routeParams, $location, FileUploader, API) ->
  $scope.associations = API.Associations.query(success, associationError)

@AssociationCtrl = ($scope, $routeParams, $location, FileUploader, API) ->
  redirectToShow = (result) ->
    $location.url('/associations/' + result.id)

  redirectToList = (result) ->
    $location.url('/associations/')

  $scope.association = {}
  if $routeParams.id
    $scope.association = API.Associations.get { id:$routeParams.id }, success, userError

  $scope.create = (assoc) -> API.Associations.save(assoc, redirectToShow, associationError)
  $scope.update = (assoc) -> assoc.$update(redirectToShow, assocError)
  $scope.delete = (assoc) ->
    if confirm 'Delete this association?'
      assoc.$remove(redirectToList, associationError)

  $scope.assocLogo = (assoc) ->
    return '/img/no-club-logo.gif' unless assoc? and assoc.logo? and assoc.logo.logo? and assoc.logo.logo.url?
    assoc.logo.logo.url

  ### Uploader for assoc ###
  csrf_token = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
  $scope.uploader = new FileUploader({
    url: '/associations/upload',
    autoUpload: true,
    headers : { 'X-CSRF-TOKEN': csrf_token },
    onCompleteItem: (item, response, status, headers) ->
      $scope.association = response

    onBeforeUploadItem: (item) ->
      item.formData.push {id: $scope.association.id}

    onErrorItem: (item, response, status, headers) ->
      $('#warning').html("Error whilst uploading avatar")
      $('#warning').addClass('alert')
      $('#warning').addClass('alert-warning')
      $('#warning').show
  })


ngApp.controller('AssociationListCtrl',   ['$scope', '$routeParams', '$location', 'API', AssociationListCtrl])
ngApp.controller('AssociationCtrl',       ['$scope', '$routeParams', '$location', 'FileUploader', 'API', AssociationCtrl])
