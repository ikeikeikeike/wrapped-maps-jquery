# -*- coding: utf-8 -*-

define ['jquery'], ($) ->
  ### wrapped-maps-jquery wrapped Google maps api v3 with jQuery and Twitter Bootstrap. ###
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


  class MAPSMODULE.BaseClass
    ### Common methods ###
    #
    #

    ### New object ###
    #
    #
    newobj: null

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

    get_newobj: ->
      ### Get map object ###
      #
      #
      @newobj


  class MAPSMODULE.Event
    ### Wrapped ###
    #
    #

    constructor: (@event=google.maps.event)
      ### Initializer ###
      #
      #

    on: (object, event, callback) ->
      ### Event listener ###
      #
      #
      @event.addListener object, event, callback


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


  class MAPSMODULE.DirectionsDisplay extends MAPSMODULE.BaseClass
    ### Wrapping class  ###
    #
    #

    ### Render options ###
    #
    #
    options:
      draggable: yes

    constructor: (directions_renderer=google.maps.DirectionsRenderer) ->
      ### Initializer ###
      #
      #

      # Set options
      if options isnt null then @set_options options
      @newobj = new @directions_renderer @options


  class MAPSMODULE.DirectionsService extends MAPSMODULE.BaseClass
    ### Wrapping class ###
    #
    #
    constructor: (@directions_service, @status=MAPSMODULE.DirectionsStatue) ->
      ### Initializer ###
      #
      #
      @newobj = new @directions_service()
      @status = new @status()


  class MAPSMODULE.Geocorder extends MAPSMODULE.BaseClass
    ### Wrapping class ###
    #
    #

    constructor: (@geocoder=google.maps.Geocoder, @status=google.maps.GeocoderStatus) ->
      ### Initializer ###
      #
      #
      @newobj = new @geocoder()

    address_to_latlng: (address, callback) ->
      ### Convert from address to latlng ###
      #
      #
      @newobj {'address': address}, (results, status) =>
        m = if status is @status.OK then "ok" else "Geocode was not successful for the following reason: #{status}"
        callback results, status, m


  class MAPSMODULE.InfoWindow extends MAPSMODULE.BaseClass
    ### Wrapping class ###
    #
    #

    ### Marker options ###
    #
    #
    options:
      position: null
      map: null
      title: null

    constructor: (@options, @marker=google.maps.Marker) ->
      ### Initializer ###
      #
      #
      @newobj = @get_new()

    get_new: (options=@options) ->
      ### Get new object ###
      #
      #
      new @marker options


  class MAPSMODULE.InfoWindow
    ### Wrapping class ###
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
      ### Create infomation and pen ###
      #
      #
      @open({content: content}) @map, @marker

    options: (options) ->
      ### Create infomation and open ###
      #
      #
      @open(options) @map, @marker


  class MAPSMODULE.Map extends MAPSMODULE.BaseClass
    ### Wrapped ###
    #
    #

    ### Render element selector ###
    #
    el: null

    ### Render options ###
    #
    #
    options:
      zoom: 14
      scrollwheel: no
      scaleControl: yes
      center: null
      mapTypeId: google.maps.MapTypeId.ROADMAP
      scaleControlOptions:
        position: google.maps.ControlPosition.BOTTOM_CENTER

    constructor: (@el_name, options=null, @map=google.maps.Map) ->
      ### Initializer ###
      #
      #
      # Set element
      @el = $ @el_name

      # Set options
      if options isnt null then @set_options options

      # New object
      @newobj = @get_new()

    get_new: (el=@el, options=@options) ->
      ### Get new map object ###
      #
      #
      new @map el.get(0), options


  class MAPSMODULE.RouteControlPanel extends MAPSMODULE.BaseClass
    ### Route search class ###
    #
    #

    ### TOP element ###
    #
    #
    el: null

    ### Controller options ###
    #
    #
    options:
      start:
        point: 'start_point_id'
        checked: 'start_checked_id'
      end:
        point: 'end_point_id'
        checked: 'end_checked_id'
      way:
        point: 'way_point_id'

    constructor: (@el_name='control_panel', options=null) ->
      ### Initializer
      @param {String} el_name - Top element name.
      @param {Object} options - Contoller options.

      .. Options, e.g. ::

          options =
            start:
              point: 'start_point_id'
              checked: 'start_checked_id'
            end:
              point: 'end_point_id'
              checked: 'end_checked_id'
            way:
              point: 'way_point_id'

      ###
      #
      #
      @el = $ @el_name

      # Set controller
      @set_selectors(options or @options)
      # gen html
      # @generate_html

    set_selectors: (selectors) ->
      ### Controller selectors ###
      #
      #

      start = selectors?.start
      start.checked
      start.point

      end = selectors?.end
      end.checked
      end.point

      way = selectors?.way
      way.point

    generate_html: (selectors) ->
      ### Generate control panel ###
      #
      #

    get_selector: (key) ->
      op = @options
      for i in key.split "."
        op = op[i]
      op

    get_element: (selector) ->
      ### ###
      #
      #
      $ selector

    set_value: (key) ->
      ### Set value to the panel ###
      #
      #
      elm = @get_element @get_selector(key)
      elm?.val value
      elm?.text value

    set_value_tostart: (value) ->
      ### ###
      #
      #
      @set_value 'start.point', value

    set_value_toend: (value) ->
      ### ###
      #
      #
      @set_value 'end.point', value

  class MAPSMODULE.RenderMap extends MAPSMODULE.BaseClass
    ### Route map class ###
    #
    #

    ### Result ###
    #
    # .. note:: Result panel
    #
    direct_panel_el: null

    ### Controller ###
    #
    #
    control_panel_el: null

    ### Control panel ###
    #
    #
    control_panel: MAPSMODULE.RouteControlPanel

    ### Map object ###
    #
    #
    map: MAPSMODULE.Map

    ### Event object ###
    #
    #
    event: MAPSMODULE.Event

    ### Direction display object ###
    #
    #
    direct_disp: null

    constructor: (@place=null, options=null) ->
      ### Initializer
      @param {String|Object} place - Address{String} or Google latlng{Object}.
      @param {Object} options - Options for rendering map.

      .. Options, e.g. ::

          options =
            direct_panel:
              name: 'direct_panel'
            control_panel:
              obj: new RouteControlPanel("control_panel")
              name: 'direct_panel'
              options: {}
            map:
              obj: new Map("map")
              name: map
              options: {}
      ###
      #
      #

      # Set direct_panel
      @direct_panel_name = options?.direct_panel.name || null
      @direct_panel_el = @direct_panel_name and $ @direct_panel_name

      # Set control panel
      @set_option_class(options, 'control_panel')

      # control_panel = options?.control_panel

      # controlobj = control_panel?.obj || null
      # if controlobj isnt null
        # @control_panel = controlobj
      # else
        # # Map options
        # name = control_panel?.name or null
        # if name is null
          # throw new Error """[RenderMap.constructor] Arguments error:
            # options.control_panel.name is require. (control_panel.name is #{name})"""
        # @control_panel = new @control_panel name, control_panel.options

      # Set map
      map = options?.map

      mapobj = map?.obj || null
      if mapobj isnt null
        @map = mapobj
      else
        # Map options
        name = map?.name or null
        if name is null
          throw new Error """[RenderMap.constructor] Arguments error:
            options.map.name is require. (map.name is #{name})"""
        @map = new @map name, map.options

    set_option_class: (options, key) ->
      ### Set class to attribute ###
      #
      #
      # Set map
      objs = options?[key]

      objs_obj = objs?.obj || null
      if objs_obj isnt null
        @[key] = objs_obj
      else
        # Obj options
        name = objs?.name or null
        if name is null
          throw new Error """[RenderMap.constructor] Arguments error:
            options.#{key}.name is require. (#{key}.name is #{name})"""
        @[key] = new @[key] name, objs.options

    set_map: (map=@map) ->
      ### Set map ###
      #
      #
      @direct_disp.setMap map

    set_direct_panel: (direct_panel_el=@direct_panel_el) ->
      ### Set panel ###
      #
      #
      if @direct_panel_el.length is 1
        @direct_disp.setPanel direct_panel_el.get(0)
      else
        console.log "[RenderMap.set_direct_panel] Arguments error: (direct_panel_el is #{direct_panel_el})"

    render_map: ->
      ### Render map ###
      #
      #

      # directionsDisplay.setMap(map);
      # directionsDisplay.setPanel(document.getElementById("directions_panel"));

      @event.on @map.get_newobj() 'click', @point_receiver

    point_receiver: (mouse_event) =>
      ### Event receiver ###
      #
      #
      @control_panel.set_points @map.get_newobj(), mouse_event.latLng


  MAPSMODULE
