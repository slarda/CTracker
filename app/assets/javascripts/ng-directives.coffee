#ngApp.directive('facebookEmbed', ['$sce', '$rootScope', ($sce, $rootScope) ->
#
#  appId = $rootScope.facebookAppId
#  appUrl = 'https://connect.facebook.net/en_US/sdk.js#xfbml=1&version=v2.6&appId=' + appId
#
#  template2 = "<div id='fb-root'></div>" +
#              "<script>(function(d, s, id) {" +
#              "var js, fjs = d.getElementsByTagName(s)[0];" +
#              "if (d.getElementById(id)) return;" +
#              "js = d.createElement(s); js.id = id;" +
#              "js.src = '" + appUrl + "';" +
#              "fjs.parentNode.insertBefore(js, fjs);" +
#              "} (document, 'script', 'facebook-jssdk'));</script>"
#
#  template1 = "<div class='fb-page' data-href='{{ pageUrl }}' data-tabs='timeline' " +
#              "data-small-header='false' data-adapt-container-width='true' data-hide-cover='false' " +
#              "data-show-facepile='true'><div class='fb-xfbml-parse-ignore'>" +
#              "<blockquote cite='{{ pageUrl }}'>" +
#              "<a ng-href='{{ pageUrl }}'>{{ name }}</a></blockquote></div></div>"
#
#  {
#    restrict: 'E',
#    template: template1 + template2,
#    scope: {
#      pageId: '@',
#      name: '@'
#    },
#    link: (scope, ele, attrs) ->
#      scope.pageUrl = $sce.trustAsUrl('https://www.facebook.com/' + attrs.pageId)
#  }
#])


ngApp.directive('twitterEmbed', ['$sce', '$rootScope', ($sce, $rootScope) ->

  template1 = "<a class='twitter-timeline' href='{{ pageUrl }}' " +
              "data-widget-id='{{ widgetId }}'>Tweets by @{{ twitterId }}</a>" +
              "<script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https'" +
              ";if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+'://platform.twitter.com/widgets.js';" +
              "fjs.parentNode.insertBefore(js,fjs);}}(document,'script','twitter-wjs');</script>"

  {
    restrict: 'E',
    template: template1,
    scope: {
      twitterId: '@',
      widgetId: '@'
    },
    link: (scope, ele, attrs) ->
      scope.pageUrl = $sce.trustAsUrl('https://twitter.com/' + attrs.twitterId)
  }
])


ngApp.directive('youtubeEmbed', ['$sce', '$rootScope', ($sce, $rootScope) ->

  # width='{{ width }}' height='{{ height }}'
  template1 = "<iframe frameborder='0' width='100%' allowfullscreen style='min-height:280px'></iframe>"

  {
    restrict: 'E',
    template: template1,
    scope: {
      url: '@',
      width: '@',
      height: '@'
    },
    link: (scope, ele, attrs) ->
      scope.videoUrl = $sce.trustAsUrl('https://www.youtube.com/embed/' + attrs.url)
      # Don't use interpolation, wait for the video URL to be fully available
      ele.find('iframe').attr('src', scope.videoUrl)
  }
])


ngApp.directive('vimeoEmbed', ['$sce', '$rootScope', ($sce, $rootScope) ->

  # width='{{ width }}' height='{{ height }}'
  template1 = "<iframe frameborder='0' width='100%' webkitallowfullscreen " +
              "mozallowfullscreen allowfullscreen style='min-height:280px'></iframe>"

  {
    restrict: 'E',
    template: template1,
    scope: {
      url: '@',
      width: '@',
      height: '@'
    },
    link: (scope, ele, attrs) ->
      scope.videoUrl = $sce.trustAsUrl('https://player.vimeo.com/video/' + attrs.url)
      # Don't use interpolation, wait for the video URL to be fully available
      ele.find('iframe').attr('src', scope.videoUrl)
  }
])


ngApp.directive('facebookVideoEmbed', ['$sce', '$rootScope', 'screenSize', ($sce, $rootScope, screenSize) ->

  # width='{{ width }}' height='{{ height }}'
  template1 = "<iframe style='border:none;overflow:hidden' " +
              "scrolling='no' frameborder='0' allowTransparency='true' allowFullScreen='true'></iframe>"

  {
    restrict: 'E',
    template: template1,
    scope: {
      url: '@',
      width: '@',
      height: '@'
    },
    link: (scope, ele, attrs) ->
      url = encodeURI((if screenSize.is('xs, sm') then "https://m.facebook.com/" else "https://www.facebook.com/") + attrs.url)
      scope.videoUrl = $sce.trustAsUrl('https://www.facebook.com/plugins/video.php?href=' + url + '&show_text=0&width=400')
      # Don't use interpolation, wait for the video URL to be fully available
      ele.find('iframe').attr('src', scope.videoUrl)
  }
])


