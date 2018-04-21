# Clubs controllers ####################################################################################################

@articleError = () ->
  $('#warning').html("Error whilst loading article content")
  $('#warning').show()

@ArticleListCtrl = ($scope, $routeParams, $location, $rootScope, sharedServices, FileUploader, API) ->

  $rootScope.current_user = API.Users.current_user success, articleError

  $scope.category = $location.url().split('/')[1]
  if $scope.category == 'health-and-wellbeing'
    $scope.page = 'health_and_wellbeing'
    $scope.page_title = 'Health and Wellbeing'
  else
    $scope.page = 'training_and_performance'
    $scope.page_title = 'Training and Performance'

  $scope.articles = API.Articles.query({category: $scope.category}, success, articleError)

  $scope.articleUrl = (article) ->
    if window.mode is 'app.champtracker.com'
      "https://app.champtracker.com/content" + article.url
    else
      "http://localhost:3000/content" + article.url

  # Shared services
  $scope.toggleButtonClass = (navCollapsed) -> sharedServices(navCollapsed)
  $scope.toggleSidebarClass = (navCollapsed) -> sharedServices(navCollapsed)

  ### Avatar uploader and cropping ###
  $scope.uploadAvatar = false
  $scope.uploadAvatarNow = () ->
    $scope.uploadAvatar = true

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



@ArticleCtrl = ($scope, $routeParams, API) ->

  redirectToShow = (result) ->
    $location.url('/articles/' + result.id)

  redirectToList = (result) ->
    $location.url('/articles/')

  $scope.page = 'articles'
  $scope.page_title = 'Articles'

  #if $routeParams.id
    #API.Articles.get { id:$routeParams.id }, (article) ->
    #, articleError

  # $sce.trustAsHtml(club.description)

#  $scope.create = (article) -> API.Articles.save(article, redirectToShow, articleError)
#  $scope.update = (article) -> article.$update(redirectToShow, articleError)
#  $scope.delete = (article) ->
#    if confirm 'Delete this article?'
#      article.$remove(redirectToList, articleError)

ngApp.controller('ArticleListCtrl',          ['$scope', '$routeParams', '$location', '$rootScope', 'sharedServices', 'FileUploader', 'API', ArticleListCtrl])
ngApp.controller('ArticleCtrl',              ['$scope', '$routeParams', 'API', ArticleCtrl])
