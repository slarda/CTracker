
@playerProfileError = () ->
  $('#warning').html("Error whilst loading or saving player profiles")
  $('#warning').addClass('alert')
  $('#warning').addClass('alert-warning')
  $('#warning').show


ngApp.directive 'simpleCarousel', ->
  return {
    restrict: 'E',
    scope: { shown: '=shown' },
    controller: ['$scope', '$element', ($scope, ele) ->
      $(ele).carousel({interval: 0})

      $scope.$watch 'shown', ->
        $(ele).carousel($scope.shown)

      this.select = (slideNum) ->
        $(ele).carousel(parseInt(slideNum))
    ]
  }

ngApp.directive 'slideLink', ->
  return {
    restrict: 'A',
    require: '^simpleCarousel',
    scope: {
      slideUpTo: '@'
    },
    link: (scope, ele, attrs, carouselCtrl) ->
      ele.on 'click', ->
        carouselCtrl.select(scope.slideUpTo)
  }

# Player profiles controllers ##########################################################################################

@PlayerProfileListCtrl = ($scope, $routeParams, $location, API) ->
  $scope.profiles = API.PlayerProfiles.query(success, playerProfileError)

@PlayerProfileCtrl = ($scope, $rootScope, $routeParams, $location, $window, $http, $timeout, sharedServices, API,
                      FileUploader) ->
  redirectToShow = (result) ->
    $scope.saving = false
    $location.url('/users/' + $routeParams.user_id + '/player_profiles/' + $scope.active)

  redirectToNewUser = (result) ->
    $scope.saving = false
    $scope.user = result
    $rootScope.current_user = result
    $location.url('/join/registered')
    # $location.url('/clubs/find')

  newUserValidationError = (result) ->
    $('#warning').html(result.data.error)
    $('#warning').addClass('alert')
    $('#warning').addClass('alert-warning')
    $('#warning').show

  redirectToNext = (result) ->
    $scope.saving = false
    if $scope.active == 'model'
      $location.url('/users/' + $routeParams.user_id + '/player_profiles/features/' + $routeParams.kind + '/' +
        $routeParams.brand + '/' + $routeParams.model)
    else if $scope.active == 'features'
      $location.url('/users/' + $routeParams.user_id + '/player_profiles/gear/')

  redirectToList = (result) ->
    $scope.saving = false
    $location.url('/player_profiles/')

  #$scope.navCollapsed = window.innerWidth <= 990

  $scope.page = $location.url().split('/')[3]
  $scope.page_title = switch $scope.page
    when 'dashboard' then 'Dashboard'
    when 'schedule' then 'Schedule'
    when 'player_profiles' then 'My Profile'
    else 'Dashboard'

  if $location.url().startsWith('/join')
    $scope.page_title = switch $location.url().split('/')[2]
      when 'registered' then "You're Registered!"
      when 'current_team' then "Your club team"
      else 'Register for FREE'

  $scope.back_button = switch $scope.page
    when 'dashboard' then false
    else true

  $scope.brand_name = ''
  $scope.cant_see = ''

  $scope.add_edit_button_text = 'Add Gear'
  $scope.add_edit_button_disabled = true

  $scope.active_tab_locker = true
  $scope.active_tab_add_edit = false
  $scope.active_tab_add_edit_gear = false
  $scope.add_gear_visible = false

  $scope.more_boots = 'Add your boots'
  $scope.more_gloves = 'Add your gloves'
  $scope.more_shin_pads = 'Add your shin pads'

  # Shared services
  $scope.toggleButtonClass = (navCollapsed)   -> sharedServices.toggleButtonClass(navCollapsed)
  $scope.toggleSidebarClass = (navCollapsed)  -> sharedServices.toggleSidebarClass(navCollapsed)
  $scope.isGoalkeeper =                       -> sharedServices.isGoalkeeper($scope)
  $scope.isCoach =                            -> sharedServices.isCoach($scope)
  $scope.backClicked =                        -> sharedServices.backClicked($window)
  $scope.currentYear =                        -> sharedServices.currentYear()

  $scope.saving = false
  $scope.alert = 'Profile successfully saved'
  $scope.saving_notice = false

  $scope.showGear = (kind) ->
    $location.url('/users/' + $routeParams.user_id + '/player_profiles/gear/add/' + kind)

  $scope.selectBrand = (kind, brand) ->
    $scope.brand = brand
    $location.url('/users/' + $routeParams.user_id + '/player_profiles/gear/add/' + kind + '/brand/' + brand.id + '/' + brand.name)

  #$scope.brands = API.Brands.query(success, playerProfileError)

  # Get the details of the active user
  $rootScope.current_user = API.Users.current_user({ id:$routeParams.user_id }, (user) ->
    if current_user.id? and (current_user.id.toString() != $routeParams.user_id.toString())
      $location.url('/users/' + $routeParams.user_id + '/dashboard')
    else
      success
  , dashboardError)
  if $routeParams.user_id
    $scope.user = API.Users.get({ id:$routeParams.user_id }, (user) ->
      if user.club?
        $scope.teams = API.Clubs.teams(id: user.club.id, success, playerProfileError)

        if $scope.active in ['brand','model','features']
          $scope.brands = API.Equipment.query(
            {
              equipment_type: $scope.kind,
              brand: $routeParams.brand,
              model: $routeParams.model
            },
            success, playerProfileError)

    , playerProfileError)
  else
    $scope.user = {}
    $scope.teams = []

  if $location.url().split('/')[1] == 'join'
    page = $location.url().split('/')[2]
    $scope.join_screen = switch page
      when 'current_team' then 2
      when 'registered' then 3
      else 1
  else
    $scope.join_screen = 0

  $scope.joinScreen = (val) ->
    $scope.join_screen = val

  $scope.isOnJoinScreen = (val) ->
    return 'active' if $scope.join_screen == val
    ''

  $scope.user.nationality = 'Australia' unless $scope.user.nationality?

  if $scope.join_screen == 1
    $scope.user.role = 'player' unless $scope.user.role?

  if $location.url().split('/')[5] == 'add'
    $scope.active_tab_add_edit_gear = true
    $scope.active_tab_locker = false
    $scope.active_tab_add_edit = false
    $scope.add_gear_visible = true
    if $location.url().split('/')[7] == 'brand'
      $scope.cant_see = "Can't see my gear"
      brand = $location.url().split('/')[8]
      $scope.brand_name = $location.url().split('/')[9]
      kind = $location.url().split('/')[6]
      $rootScope.current_user.$promise.then (current_user) ->
        API.Equipment.query({brand_id: brand, equipment_type: kind, sport: current_user.active_sport}, (equipment) ->
          $scope.equipment = equipment
          $scope.carousel_slide = 1
        , playerProfileError)
    else
      $scope.cant_see = "Can't see my gear's brand"
      $scope.kind = $location.url().split('/')[6]
      $rootScope.current_user.$promise.then (current_user) ->
        $scope.brands = API.Brands.query({kind: $scope.kind, sport: current_user.active_sport}, success, playerProfileError)

  if $routeParams.kind
    $scope.kind = $routeParams.kind
  else
    $scope.kind = 'boots'

#  $scope.selectModel = (model) ->
#    API.Equipment.query({brand_id: brand.id, equipment_type: 'boots'}, (equipment) ->
#      $scope.equipment = equipment
#      $scope.carousel_slide = 1
#    , playerProfileError)

  $scope.toggleSelection = (model) ->
    if model.selectedClass? and model.selectedClass is 'selected'
      equipment.selectedClass = '' for equipment in $scope.equipment
      model.selectedClass = ''
      $scope.add_edit_button_disabled = true
      $scope.selected = null
    else
      equipment.selectedClass = '' for equipment in $scope.equipment
      model.selectedClass = 'selected'
      $scope.add_edit_button_disabled = false
      $scope.selected = model

  $scope.capitalize = (text) ->
    text = text.replace /\w\S*/g, (txt) ->
      txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase()
    text = 'Shin Pads' if text is 'Shinpads'
    text

  $scope.cancelGear = ->
    $location.url('/users/' + $routeParams.user_id + '/player_profiles/gear')

  $scope.addSelectedGear = (equipment) ->
    player_equipment = new API.PlayerEquipment
    player_equipment.model = equipment.model
    player_equipment.equipment_type = equipment.equipment_type
    player_equipment.brand = equipment.brand.name if equipment.brand?
    player_equipment.variations = equipment.variations
    player_equipment.equipment_id = equipment.id
    player_equipment.$save({id: $rootScope.current_user.id}, redirectToShow, playerProfileError)
    $scope.active_tab_locker = true
    $scope.active_tab_add_edit_gear = false
    $scope.active_tab_add_edit = false
    $scope.carousel_slide = 0
    $scope.user.player_equipments.push(player_equipment)
    $location.url('/users/' + $routeParams.user_id + '/player_profiles/gear')

  $scope.moreGear = (kind) ->
    return 'btn-default btn-sm' unless $scope.user? and $scope.user.player_equipments?
    set = (e for e in $scope.user.player_equipments when e.equipment_type is kind)
    if set? and set.length > 0
      $scope.more_boots = 'Add more boots' if kind is 'boots'
      $scope.more_gloves = 'Add more gloves' if kind is 'gloves'
      $scope.more_shin_pads = 'Add more shin pads' if kind is 'shinpads'
    if set? and set.length == 0 then 'btn-primary' else 'btn-default btn-sm'

  $scope.removeGear = (gear) ->
    gearRes = new API.PlayerEquipment(gear)
    gearRes.$remove(->
      index = $scope.user.player_equipments.indexOf(gear)
      $scope.user.player_equipments.splice(index, 1) if index >= 0
    , playerProfileError)


#  $scope.playerGearPhoto = (gear) ->
#    return gear.equipment_photos[0].photo.url if gear.equipment_photos.length > 0
#    return "/img/tmp/gear/boots-sample.jpg" if gear.equipment_type is "boots"
#    return "/img/tmp/gear/glove-sample.jpg" if gear.equipment_type is "gloves"
#    return "/img/tmp/gear/glove-sample.jpg" if gear.equipment_type is "shinpads"

  $scope.gearPhoto = (gear) ->
    return '' unless gear? and gear.equipment_photos?
    return gear.equipment_photos[0].photo.thumb.url if gear.equipment_photos.length > 0 and
      gear.equipment_photos[0].photo? and gear.equipment_photos[0].photo.thumb?
    return "/img/tmp/gear/boots-sample.jpg" if gear.equipment_type is "boots"
    return "/img/tmp/gear/glove-sample.jpg" if gear.equipment_type is "gloves"
    return "/img/tmp/gear/glove-sample.jpg" if gear.equipment_type is "shinpads"

  $scope.brandPhoto = (brand) ->
    return brand.logo.thumb.url if brand.logo? and brand.logo.thumb? and brand.logo.thumb.url?
    "/img/gear/brand-logos/Logo_NIKE.svg"

  # Avatar uploader and cropping
  $scope.uploadAvatar = false
  $scope.uploadAvatarNow = () ->
    $scope.uploadAvatar = true

  $scope.clubLogo = (user) ->
    return '/img/no-club-logo.gif' unless user? and user.club? and user.club.logo? and user.club.logo.url?
    user.club.logo.url

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

  #  # From https://github.com/LukeMason/angular-img-editor
  #  $scope.uploader.uploadItem = (value) ->
  #    index = this.getIndexOfItem(value)
  #    item = this.queue[index]
  #    item.index = item.index || this._nextIndex++
  #    item.isReady = true
  #    filename = item.file.name.split('.')
  #    filename.pop()
  #    filename = filename.join('.')
  #
  #    # Debounce
  #    return if this.isUploading
  #    this.isUploading = true
  #
  #    that = this
  #    $http({
  #      method: 'POST',
  #      url: item.url,
  #      data: {
  #        base64: item.base64,
  #        name: filename,
  #        type: item.file.type
  #      }
  #    }).success( (data, status, headers, config) ->
  #      xhr = {
  #        response: data,
  #        status: status,
  #        dummy: true
  #      }
  #      console.log(that.trigger)
  #      that.trigger('in:success', xhr, item, data)
  #      that.trigger('in:complete', xhr, item, data)
  #    ).error( (data, status, headers, config) ->
  #      alert('error on cropping avatar image')
  #      console.log(data)
  #      xhr = {
  #        response: data,
  #        status: status,
  #        dummy: true
  #      }
  #      that.trigger('in:error', xhr, item)
  #      that.trigger('in:complete', xhr, item)
  #    )

  #  $scope.uploader.filters.push (item) ->
  #    type = if $scope.uploader.isHTML5 then item.type else '/' + item.value.slice(item.value.lastIndexOf('.') + 1)
  #    type = '|' + type.toLowerCase().slice(type.lastIndexOf('/') + 1) + '|'
  #    '|jpg|png|jpeg|bmp|gif|'.indexOf(type) != -1

  #  $scope.uploader.onSuccess = (event, xhr, item, response) ->
  #    console.info('Success', xhr, item, response)
  #
  #  $scope.uploader.onCancel = (event, xhr, item) ->
  #    console.info('Cancel', xhr, item)
  #
  #  $scope.uploader.onError = (event, xhr, item, response) ->
  #    console.info('Error', xhr, item, response)

  # Equipment type filters
  $scope.boots = {equipment_type: 'boots'}
  $scope.guards = {equipment_type: 'guards'}
  $scope.gloves = {equipment_type: 'gloves'}

  # Positions
  $rootScope.current_user.$promise.then (current_user) ->
    $scope.positions = API.Positions.query {sport: current_user.active_sport}, success, playerProfileError

  # Currently active tab in menu
  $scope.active = $location.url().split('/')[4]
  $scope.is_active = (test) ->
    if test == $scope.active
      'active'
    else
      ''

  # Action button text
  if $scope.active == 'model'
    $scope.save_action = 'Select Features'
  else if $scope.active == 'features'
    $scope.save_action = 'Add Apparel'
  else
    $scope.save_action = 'Save Profile'

#  $scope.addGear = (user, gear) ->
#    user.player_equipments.push(gear)
#    user.player_equipments[user.player_equipments.length-1]['id'] = null
#    user.player_equipments[user.player_equipments.length-1]['user_id'] = user.id

  $scope.create = (user) -> API.Users.save(user, redirectToNewUser, newUserValidationError)
  $scope.update = (user) ->
    $scope.saving = true
    if $scope.active in ['model','features']
      user.$update(redirectToNext, playerProfileError)
    else
      user.$update(redirectToShow, playerProfileError)
      $scope.saving_notice = true
      $timeout(->
        $scope.saving_notice = false
      , 1500)
  $scope.delete = (profile) ->
    if confirm 'Delete this player profile?'
      profile.$remove(redirectToList, playerProfileError)

#  $rootScope.$on '$viewContentLoaded', (event) ->
#    $('button[data-loading-text]').click ->
#      $(this).button('loading')


ngApp.controller('PlayerProfileListCtrl', ['$scope', '$routeParams', '$location', 'API', PlayerProfileListCtrl])
ngApp.controller('PlayerProfileCtrl',     ['$scope', '$rootScope', '$routeParams', '$location', '$window', '$http',
                                           '$timeout', 'sharedServices', 'API', 'FileUploader', PlayerProfileCtrl])
