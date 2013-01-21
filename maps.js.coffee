# -*- coding: utf-8 -*-

define ['jquery'], ($) ->
  ###
  @name          wrapped-maps-jquery
  @description   A jQuery plugin for Google maps api v3.
  @homepage      https://github.com/ikeikeikeike/wrapped-maps-jquery
  @support_url   https://github.com/ikeikeikeike/wrapped-maps-jquery/issues
  ###
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
      jQuery("html")
    catch error
      throw error

  try
    module_checker()
  catch error
    console.log "[wrapped-maps-jquery] Required module error: #{error}, Required module in maps.js."


  ### Main object ###
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
      ### Get new object ###
      #
      #
      @newobj

    set_newobj: (@newobj) ->
      ### Set new object ###
      #
      #

    set_value: (value) ->
      ### Set value to a dom ###
      #
      #
      (@el?.val? or @el?.text?) value

    get_value: (key) ->
      ### Get value of a dom ###
      #
      #
      (@el?.val? or @el?.text?)()

    compute: (num) ->
      ### Compute lat and lng ###
      #
      #
      Math.round(num * 1000000000) / 1000000000


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

    get_message: (status) ->
      ### Get status message ###
      #
      #
      @statues[status]


  class MAPSMODULE.DirectionsRenderer extends MAPSMODULE.BaseClass
    ### Wrapping class  ###
    #
    #

    ### Render options ###
    #
    #
    options:
      draggable: yes

    constructor: (@panel_name, options=null, @directions_renderer=google.maps.DirectionsRenderer) ->
      ### Initializer ###
      #
      #

      # Set options
      if options isnt null then @set_options options
      @set_newobj new @directions_renderer(@options)
      @set_panel @panel_name

    set_map: (map) ->
      ### Set map object ###
      #
      #
      @get_newobj().setMap map

    set_panel: (panel_name=@panel_name) ->
      ### Set panel element name ###
      #
      #
      @get_newobj().setPanel panel_name

    set_directions: (results) ->
      ### Set directionsService.route response results ###
      #
      #
      @get_newobj().setDirections results


  class MAPSMODULE.DirectionsService extends MAPSMODULE.BaseClass
    ### Wrapping class ###
    #
    #

    ### Route options ###
    #
    #
    options:
      origin: ''
      destination: ''
      waypoints: ''
      optimizeWaypoints: true
      avoidHighways: true
      avoidTolls: true
      travelMode: google.maps.DirectionsTravelMode.DRIVING
      # transitOptions: {
        # departureTime: new Date(1337675679473)
      # }
      # travelMode: google.maps.DirectionsTravelMode.TRANSIT
      # unitSystem: google.maps.UnitSystem.IMPERIAL

    constructor: (options=null, @directions_service=google.maps.DirectionsService, @status=MAPSMODULE.DirectionsStatue) ->
      ### Initializer ###
      #
      #
      @set_newobj new @directions_service()
      @status = new @status()

    route: (options=@options, callback) ->
      ### Request route ###
      #
      #
      self = @
      @get_newobj().route options, (response, status) ->
        if status == google.maps.DirectionsStatus.OK
          callback(response)
        else
          console.log "Directions Service ERROR: #{status}\n#{self.status.get_message status}"


  class MAPSMODULE.Geocorder extends MAPSMODULE.BaseClass
    ### Wrapping class ###
    #
    #

    constructor: (@geocoder=google.maps.Geocoder, @status=google.maps.GeocoderStatus) ->
      ### Initializer ###
      #
      #
      @set_newobj new @geocoder()

    address_to_latlng: (address, callback) ->
      ### Convert from address to latlng ###
      #
      #
      @get_newobj().geocode {'address': address}, (results, status) =>
        m = if status is @status.OK then "ok" else "Geocode was not successful for the following reason: #{status}"
        callback results, status, m


  class MAPSMODULE.Marker extends MAPSMODULE.BaseClass
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
      @set_newobj @get_new()

    get_new: (options=@options) ->
      ### Get new object ###
      #
      #
      new @marker options


  class MAPSMODULE.InfoWindow extends MAPSMODULE.BaseClass
    ### Wrapping class ###
    #
    #
    options:
      map: null
      marker: null
      content: ''

    default_template: """
    <div class="">
      <div class="modal-header modal-header-wrapper">
        <h3>{title}</h3>
      </div>
      <div class="modal-body">
        {body}
      </div>
    </div>
    """

    constructor: (@el_name='#infowindow', @optins=null, @infowindow=google.maps.InfoWindow) ->
      ### Initializer ###
      #
      #
      @el = $ @el_name

      # Set options
      if options isnt null then @set_options options

    get_template: () ->
      ### Get default template or Element ###
      #
      #
      if @el.is '*'
        @el.html()
      else
        @default_template

    render_template: (title, body) ->
      ### ###
      #
      #
      template = template.replace '{title}', title
      template.replace '{body}', body

    open: (map=@options.map, marker=@options.marker) ->
      ### Open info window ###
      #
      #


  class MAPSMODULE.Map extends MAPSMODULE.BaseClass
    ### Wrapped ###
    #
    #

    ### Render element selector ###
    #
    el: null

    ### Renderer options ###
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

    constructor: (@el_name='#googlemaps', options=null, @map=google.maps.Map) ->
      ### Initializer ###
      #
      #
      # Set element
      @el = $ @el_name

      # Set options
      if options isnt null then @set_options options

      # New object
      @set_newobj @get_new()

    get_new: (el=@el, options=@options) ->
      ### Get new map object ###
      #
      #
      new @map el.get(0), options

    get_address: ->
      ### Address ###
      #
      #
      @el.attr 'address'

    get_title: ->
      ### Title ###
      #
      #
      @el.attr 'title'

    get_content: ->
      ### Content ###
      #
      #
      @el.attr 'content'

  class MAPSMODULE.RouteInfoPanel extends MAPSMODULE.BaseClass
    ### Route infomation panel ###
    #
    #

    ### TOP element ###
    #
    #
    el: null

    constructor: (@el_name='#info_panel') ->
      ### Initializer ###
      #
      #
      @el = $ @el_name

    set_total_distance: (results, object) ->
      ### Set total distance ###
      #
      #
      data = ''
      for routes in results.routes
        for overview_path in routes.overview_path
          data += "#{@compute overview_path.lng()},#{@compute overview_path.lat()}\n"
      @set_value data


  class MAPSMODULE.RouteDirectionsPanel extends MAPSMODULE.BaseClass
    ### Route result panel ###
    #
    #

    ### TOP element ###
    #
    #
    el: null

    ### Rirections options ###
    #
    #
    options:
      total: '#total'

    constructor: (@el_name='#directions_panel', options=null) ->
      ### Initializer
      @param {String} el_name - Top element name.
      @param {Object} options - options.

      .. Options, e.g. ::

          options =
            total: '#total'
      ###
      #
      #
      @el = $ @el_name

    set_total_distance: (results, object) ->
      ### Set total distance ###
      #
      #
      total = 0
      for legs in results.routes[0].legs
        total += legs.distance.value
      @el.find(@options.total).text total / 1000 + " km"

  class MAPSMODULE.RouteControlPanel extends MAPSMODULE.BaseClass
    ### Route controller panel ###
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
      focus:
        input: true
        next: true
      start:
        point: '#start_point'
        checked: '#start_checked'
      end:
        point: '#end_point'
        checked: '#end_checked'
      way:
        point: '#way_point'
        checked: '#way_checked'
        nontollway: '#way_nontollway'
        nonhighway: '#way_nonhighway'
      # event:
        # route: '#click_route'
        # clearaddr: '#click_clearaddr'
      event:
        route:
          id: '#click_route'
          event:
            click: (event, cls) ->
        clearaddr:
          id: '#click_clearaddr'
          event:
            click: (event, cls) ->

    constructor: (@el_name='#control_panel', options=null) ->
      ### Initializer
      @param {String} el_name - Top element name.
      @param {Object} options - Contoller options.

      .. Options, e.g. ::

          options =
            focus:
              input: true
              next: true
            start:
              point: '#start_point'
              checked: '#start_checked'
            end:
              point: '#end_point'
              checked: '#end_checked'
            way:
              point: '#way_point'
              checked: '#way_checked'
              nontollway: '#way_nontollway'
              nonhighway: '#way_nonhighway'

            ## event or event ##
            event:
              route: '#click_route'
              clearaddr: '#click_clearaddr'
            event:
              route:
                id: '#click_route'
                event:
                  click: (event, cls) ->
              clearaddr:
                id: '#click_clearaddr'
                event:
                  click: (event, cls) ->
                  dblclick: (event, cls) -> # TODO: Multiple event, Not implemention.
      ###
      #
      #
      @el = $ @el_name

      # Set controller
      @set_selectors(options or @options)
      # gen html

      # @generate_html

      # Push latlng value
      if @options.focus.input is true then @push_value()

      # Add event auto flg
      # @add_events(callback)

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
      way.checked
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

    get_element: (key) ->
      ### ###
      #
      #
      $ @get_selector(key)

    set_value: (key, value) ->
      ### Set value to a panel ###
      #
      #
      elm = @get_element key
      (elm?.val? or elm?.text?) value

    get_value: (key) ->
      ### Get value of a panel ###
      #
      #
      elm = @get_element key
      (elm?.val? or elm?.text?)()

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

    set_value_toway: (value) ->
      ### ###
      #
      #
      @set_value 'way.point', "#{@get_value 'way.point'}#{value}\n"

    set_point: (latlng, object=null) ->
      ### Set latLng to dom and next focus. ###
      #
      #
      if is_checked 'start.checked'
        @set_value_tostart latlang
        @next_focus 'start.point'
      else if is_checked 'end.checked'
        @set_value_toend latlang
        @next_focus 'end.point'
      else if is_checked 'way.checked'
        @set_value_toway latlang
      else
        console.log '[RouteControlPanel.set_point] Not checked error.'

    next_focus: (key) ->
      ### Next focus for input text ###
      #
      #
      if @options.focus.next
        @get_element(
          if key is "start.point"
            "end.point"
          else if key is "end.point"
            "way.point"
        ).focus()

    is_checked: (key) ->
      ### Check push value element ###
      #
      #
      elm = @get_element key

      if elm.checked
        true
      else if @_push_value_el is null
        false
      else if @_push_value_el.is elm
        true
      else
        false

    ### Current fucus element ###
    #
    #
    _push_value_el: null
    push_value: ->
      ### Set current focus ###
      #
      #
      self = @
      @get_element('start.point').focus(-> self._push_value_el = $ @).blur -> self._push_value_el = null
      @get_element('end.point').focus(-> self._push_value_el = $ @).blur -> self._push_value_el = null
      @get_element('way.point').focus(-> self._push_value_el = $ @).blur -> self._push_value_el = null

    _get_objkey: (object) ->
      ### For one object ###
      #
      #
      (k for k, v of object)[0]

    _get_objvalue: (object) ->
      ### For one object ###
      #
      #
      (v for k, v of object)[0]

    on: (object=null) ->
      ### Utility ###
      #
      #
      $(object.id).on object.event, {maincallback: object.maincallback, usercallback: object.usercallback}, object.method

    add_route_event: (object=null) ->
      ### Add events listener ###
      #
      # Route event
      #
      if not @options.event
        @on
          id: @options.event.route
          event: 'click'
          method: @on_route
          callback:
            main: callback
            user: null
      else
        route = @options.event.route
        @on
          id: route.id
          event: @_get_objkey route
          method: @on_route
          callback:
            main: callback
            user: @_get_objvalue route

    add_clearaddr_event: (object=null) ->
      ### Add events listener ###
      #
      # ClearAddress event
      #
      if not @options.event
        @on
          id: @options.event.clearaddr
          event: 'click'
          method: @on_clearaddr
          callback:
            main: callback
            user: null
      else
        clearaddr = @options.event.clearaddr
        @on
          id: clearaddr.id
          event: @_get_objkey clearaddr
          method: @on_clearaddr
          callback:
            main: callback
            user: @_get_objvalue clearaddr

    on_clearaddr: (event) ->
      ###  ###
      #
      #
      event?.usercallback()
      event?.maincallback()

    on_route: (event) ->
      ### Route search request ###
      #
      #

      # Start
      start = @get_value 'start.point'
      # End
      end = @get_value 'end.point'
      # Non highway
      hw = if @get_element("way.nonhighway").checked then true else false
      # Non tollway
      toll = if @get_element("way.nontollway").checked then true else false
      # Way point
      waypts = []
      for wats in @get_value("way.point").split "\n"
        if wats != '' then waypts.push {location: wats, stopover: true}

      # Add parameter
      event.control_panel =
        options: {start, end, hw, toll, waypts}

      # Call
      event?.usercallback event, @
      event?.maincallback event, @

  class MAPSMODULE.RenderRouteMap extends MAPSMODULE.BaseClass
    ### Route map class ###
    #
    #

    ### Control panel ###
    #
    #
    control_panel: MAPSMODULE.RouteControlPanel

    ### Result panel ###
    #
    #
    direct_panel: MAPSMODULE.RouteDirectionsPanel

    ### Info panel ###
    #
    #
    info_panel: MAPSMODULE.RouteInfoPanel

    ### Direction Renderer object ###
    #
    #
    direct_render: MAPSMODULE.DirectionsRenderer

    ### Direction Service object ###
    #
    #
    direct_service: MAPSMODULE.DirectionsService

    ### Map object ###
    #
    #
    map: MAPSMODULE.Map

    ### Marker object ###
    #
    #
    marker: MAPSMODULE.Marker

    ### InfoWindow object ###
    #
    #
    infowindow: MAPSMODULE.InfoWindow

    ### Event object ###
    #
    #
    event: MAPSMODULE.Event

    ### Geocorder object ###
    #
    #
    geocorder: MAPSMODULE.Geocorder

    constructor: (options=null) ->
      ### Initializer
      @param {String|Object} place - Address{String} or Google latlng{Object}.
      @param {Object} options - Options for rendering map.

      .. Options, e.g. ::

          options =
            direct_panel:
              obj: new RouteDirectionsPanel("#directions_panel")
              name: '#directions_panel'
              options: null
            control_panel:
              obj: new RouteControlPanel("#control_panel")
              name: '#direct_panel'
              options: {}
            info_panel:
              obj: new RouteInfoPanel("#info_panel")
              name: '#info_panel'
              options: {}
            direct_render:
              obj: new DirectionsRenderer('#renderer')
              name: '#renderer'
              options: {}
            map:
              obj: new Map("#map")
              name: '#map'
              options: {}

      ###
      #
      #

      # Set direct_panel
      @set_option_class options, 'direct_panel'

      # Set control panel
      @set_option_class options, 'control_panel'

      # Set info_panel
      @set_option_class options, 'info_panel'

      # Set directions renderer
      @set_option_class options, 'direct_render'

      # Set map
      @set_option_class options, 'map'

      # new
      @set_option_class options, 'geocorder'

      # My options
      @place = options?.place

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
          console.log "[RenderRouteMap.constructor] Arguments error: options.#{key}.name is require. (#{key}.name is #{name})"
        @[key] = new (
          if (v for v of objs?.options).length
            (@[key] name, objs.options)
          else if name
            (@[key] name)
          else
            @[key]
        )

    run: (options={}) ->
      ### Render map ###
      #
      #
      @get_latlng options?.place, (results, status, message) =>
        ### Current latlng ###
        #
        #
        latlng = results[0].geometry.location
        console.log '[run] Request address: ', results, status, message

        # Set map to panel.
        @set_map()

        # Set directions panel
        @set_direct_panel()

        #
        @open_infowindow latlng

        ###
        # @event.on @map.get_newobj() 'click', @click_event_receiver_formap

          var myOptions = {
              zoom: 14,
              scrollwheel: false,
              scaleControl: true,
              center: latlng,
              mapTypeId: google.maps.MapTypeId.ROADMAP,
              scaleControlOptions: {position: google.maps.ControlPosition.BOTTOM_CENTER}
          }

          map = new google.maps.Map(document.getElementById("googlemaps"), myOptions);
          directionsDisplay.setMap(map);
          directionsDisplay.setPanel(document.getElementById("directions_panel"));

          marker = new google.maps.Marker({
            position: latlng,   // マーカーの位置
            map: map,   // 表示する地図
            title: title   // ロールオーバー テキスト
          });

          // 吹き出しを作成します
          infowindow = new google.maps.InfoWindow({content: content});

          // 吹き出しをオープンします
          infowindow.open(map, marker);

          // クリックしたときに吹き出しがオープンするイベントを定義します
          google.maps.event.addListener(marker, 'click', function() {
            infowindow.open(map, marker);
          });

          google.maps.event.addListener(map, 'click', function(mouseEvent) {
              setPoints(map, mouseEvent.latLng);
          });
          google.maps.event.addListener(directionsDisplay, 'directions_changed', function() {
              computeTotalDistance(directionsDisplay.directions);
          });

        ###

    get_latlng: (place=@place, callback) ->
      ### Get latlng ###
      #
      #
      @geocorder.address_to_latlng place or @map.get_address(), (results, status, message) ->
        callback results, status, message

    get_marker: (latlng, title=@map.get_title(), map=@map.get_newobj()) ->
      ### Get marker object ###
      #
      #
      new @marker
        positoin: latlng
        title: title
        map: map

    @open_info: (latlng, map=@map.get_newobj()) ->
      ### Open info window ###
      #
      #
      # Get marker object
      marker = @get_marker latlng
      @infowindow.open map, marker

    set_map: (map=@map.get_newobj()) ->
      ### Set map ###
      #
      #
      @direct_render.set_map map

    set_direct_panel: (direct_panel_el=@direct_panel.el) ->
      ### Set panel ###
      #
      #
      if direct_panel_el.is '*'
        @direct_render.set_panel direct_panel_el.get 0
      else
        console.log "[RenderRouteMap.set_direct_panel] Arguments error: (direct_panel_el is #{direct_panel_el})"

    click_event_receiver_route: (event, cls) =>
      ### From control panel ###
      #
      #

    click_event_receiver_clearaddr: (event, cls) =>
      ### From control panel ###
      #
      #

    click_event_receiver_formarker: (event) =>
      ### Mouse event receiver ###
      #
      #
      @infowindow.open @map.get_newobj(), @marker.get_newobj()

    click_event_receiver_formap: (event) =>
      ### Mouse event receiver ###
      #
      #
      @control_panel.set_point event.latLng, @map.get_newobj()

    directions_changed_receiver_formap: (event) ->
      ### Directions changed event receiver ###
      #
      #
      newobj = @direct_render.get_newobj()
      @direct_panel.set_total_distance newobj.directions, newobj
      @info_panel.set_total_distance newobj.directions, newobj


  MAPSMODULE
