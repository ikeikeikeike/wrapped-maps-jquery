# -*- coding: utf-8 -*-

define ['jquery'], ($) ->
  ### Google maps api v3 wrapped module ###
  #
  #

  module_checker = ->
    ### Using modules ###
    #
    #
    try
      google.maps.Geocoder
      google.maps.GeocoderStatus
      google.maps.DirectionsTravelMode
      google.maps.DirectionsRenderer
      google.maps.DirectionsService
      google.maps.DirectionsStatus
      google.maps.ControlPosition
      google.maps.InfoWindow
      google.maps.LatLng
      google.maps.Map
      google.maps.Marker
      google.maps.MapTypeId
      google.maps.event
    catch error
      throw error

  try
    module_checker()
  catch error
    console.log "Required module in maps.js:: #{error}"

  ### Return object ###
  #
  #
  MAPSMODULE = {}


  class MAPSMODULE.DirectionsStatue
    ### Status Errors ###
    #
    # .. Direction service response statues ::
    #
    #       OK
    #       MAX_WAYPOINTS_EXCEEDED
    #       NOT_FOUND
    #       INVALID_REQUEST
    #       OVER_QUERY_LIMIT
    #       REQUEST_DENIED
    #       UNKNOWN_ERROR
    #       ZERO_RESULTS
    #

    # Errors
    statues: []

    constructor: (@directions_status=google.maps.DirectionsStatus) ->
      ### Initializer ###
      #
      #
      @statues[@directions_status.INVALID_REQUEST] = 'DirectionsRequest が無効'
      @statues[@directions_status.MAX_WAYPOINTS_EXCEEDED] = '経由点がが多すぎます。経由点は 8 以内です。'
      @statues[@directions_status.NOT_FOUND] = 'いずれかの点が緯度経度に変換できませんでした。'
      @statues[@directions_status.OVER_QUERY_LIMIT] = '単位時間当りのリクエスト制限回数を超えました。'
      @statues[@directions_status.REQUEST_DENIED] = 'このサイトからはルートサービスを使用できません。'
      @statues[@directions_status.UNKNOWN_ERROR] = '不明なエラーです。もう一度試すと正常に処理される可能性があります。'
      @statues[@directions_status.ZERO_RESULTS] = 'ルートを見つけられませんでした。'

    getMessage: (status) ->
      ### Get status message ###
      #
      #
      @statues[status]


  class MAPSMODULE.Geocorder
    ### Geocoder class ###
    #
    #

    constructor: (@geocoder=google.maps.Geocoder, @status=google.maps.GeocoderStatus) ->
      ### Initializer ###
      #
      #
      @geocoder = new @geocoder()

    address_to_latlng: (address, callback) ->
      ### Convert from address to latlan ###
      #
      #
      @geocode {'address': address}, (results, status) =>
        m = if status is @status.OK then "ok" else "Geocode was not successful for the following reason: #{status}"
        callback results, status, m

  class MAPSMODULE.InfoWindow
    ### 吹き出し ###
    #
    #

    constructor: (@map, @marker, @info_window=google.maps.InfoWindow) ->
      ### Initializer ###
      #
      #

    open: (options) ->
      ### open ###
      #
      #
      new @info_window(options).open

    content: (content) ->
      ### 吹き出しを作成 and open ###
      #
      #
      @open({content: content}) @map, @marker

    options: (options) ->
      ### 吹き出しを作成 and open ###
      #
      #
      @open(options) @map, @marker


  class MAPSMODULE.RouteSearch
    ### Route search class ###
    #
    #

    constructor: () ->


  class MAPSMODULE.RenderMap
    ### Route search class ###
    #
    #

    ### Render element selector ###
    #
    el: null

    options:
      zoom: 14
      scrollwheel: no
      scaleControl: yes
      center: null
      mapTypeId: google.maps.MapTypeId.ROADMAP
      scaleControlOptions:
        position: google.maps.ControlPosition.BOTTOM_CENTER

    constructor: (@el_name, options=null) ->
      ### Initializer ###
      #
      #
      # Set element
      @el = $ @el_name
      # Set options
      if options isnt null then @set_options options

    get_options: ->
      ### Get options ###
      #
      #
      @options

    set_options: (objects) ->
      ### Set options by objects ###
      #
      #
      for key, value of objects
        @options[key] = value



















  MAPSMODULE
