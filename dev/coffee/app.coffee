
generateMap = ->
  pin = new google.maps.LatLng(39.7775760, 30.5109010)

  mapStyle = [
    {
      featureType: "water"
      elementType: "geometry"
      stylers: [
        {
          color: "#000000"
        }
        {
          lightness: 17
        }
      ]
    }
    {
      featureType: "landscape"
      elementType: "geometry"
      stylers: [
        {
          color: "#000000"
        }
        {
          lightness: 20
        }
      ]
    }
    {
      featureType: "road.highway"
      elementType: "geometry.fill"
      stylers: [
        {
          color: "#000000"
        }
        {
          lightness: 17
        }
      ]
    }
    {
      featureType: "road.highway"
      elementType: "geometry.stroke"
      stylers: [
        {
          color: "#000000"
        }
        {
          lightness: 29
        }
        {
          weight: 0.2
        }
      ]
    }
    {
      featureType: "road.arterial"
      elementType: "geometry"
      stylers: [
        {
          color: "#000000"
        }
        {
          lightness: 18
        }
      ]
    }
    {
      featureType: "road.local"
      elementType: "geometry"
      stylers: [
        {
          color: "#000000"
        }
        {
          lightness: 16
        }
      ]
    }
    {
      featureType: "poi"
      elementType: "geometry"
      stylers: [
        {
          color: "#000000"
        }
        {
          lightness: 21
        }
      ]
    }
    {
      elementType: "labels.text.stroke"
      stylers: [
        {
          visibility: "on"
        }
        {
          color: "#000000"
        }
        {
          lightness: 16
        }
      ]
    }
    {
      elementType: "labels.text.fill"
      stylers: [
        {
          saturation: 36
        }
        {
          color: "#000000"
        }
        {
          lightness: 40
        }
      ]
    }
    {
      elementType: "labels.icon"
      stylers: [visibility: "off"]
    }
    {
      featureType: "transit"
      elementType: "geometry"
      stylers: [
        {
          color: "#000000"
        }
        {
          lightness: 19
        }
      ]
    }
    {
      featureType: "administrative"
      elementType: "geometry.fill"
      stylers: [
        {
          color: "#000000"
        }
        {
          lightness: 20
        }
      ]
    }
    {
      featureType: "administrative"
      elementType: "geometry.stroke"
      stylers: [
        {
          color: "#000000"
        }
        {
          lightness: 17
        }
        {
          weight: 1.2
        }
      ]
    }
  ]

  mapOptions =
    zoom: 17
    disableDefaultUI: true
    center: pin
    scrollwheel: false
    # draggable: false
    optimized: false
    # zoomControl:true
    # zoomControlOptions:
    #   style: google.maps.ZoomControlStyle.SMALL
    #   position: google.maps.ControlPosition.RIGHT_CENTER

  map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions)

  styledMapOptions = 
    name: 'Hello App'

  mapStyleOption = new google.maps.StyledMapType(mapStyle, styledMapOptions)

  map.mapTypes.set('mapStyleOption', mapStyleOption)
  map.setMapTypeId('mapStyleOption')

  marker = new MarkerWithLabel(
     position: pin
     icon:
      path: ''
     map: map
     labelContent: "<span class='icon-logo'></span>"
     labelAnchor: new google.maps.Point(25, 31)
     labelClass: "map-marker"
  )

  google.maps.event.addListener marker, 'click' , () ->
    mapLink()

  google.maps.event.addDomListener window, 'resize', () ->
    map.panTo(marker.getPosition())
    return

angular.module 'hello', [
  'ngSanitize',
]

angular.module 'hello'
.controller 'AppCtrl', ($scope, $http,$sce) ->

  $scope.slugify = (text) ->
    return text.toLowerCase().replace(/[^\w ]+/g, "").replace RegExp(" +", "g"), "-"
        
  $scope.n2Br = (text) ->
    if text
      text = text.replace(/\n/g, "<br />")
    else
      text = ""
    return text

  $scope.socialCount = (count) ->
    count = parseInt count,10
    if count > 0
      if count > 1000
        if count < 10000
          count = Math.round((count / 1000)*10)/10 + "K"
        else
          count = Math.round((count / 1000)) + "K"
    else
      count = ":)"
    return count
 
  return @

.directive 'socialButtons', ($http) ->
  restrict: 'C'
  link: (scope, element, attrs) ->

    $http
      cache: true
      method: 'GET'
      url: '/social/all'

    .success (data,status) ->
      $(window).on 'load', ()->
        scope.$apply () ->
          scope.social = data

    .error (data,status) ->
      scope.social = data || "Request failed"
      scope.status = status


.run (handy) ->

  $(document).hammer
    stop_browser_behavior:
      userselect: false  

  .bind 'touchmove', (e)->
      e.preventDefault()

  $('.container').bind 'touchmove', (e)->
    e.stopPropagation()
