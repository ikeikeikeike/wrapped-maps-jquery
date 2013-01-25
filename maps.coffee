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

  ### Main object ###
  #
  #
  MAPSMODULE = {}


  MAPSMODULE.module_checker = ->
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
      console.log "[wrapped-maps-jquery] Required module error: #{error}, Required module in maps.js."
      return no
    yes

  if MAPSMODULE.module_checker() is false then return MAPSMODULE

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

    set_value: (value, el=@el) ->
      ### Set value to a dom ###
      #
      #
      if el.is("[type='text'],textarea")
        el.val value
      else
        el.text value

    get_value: (el=@el) ->
      ### Get value of a dom ###
      #
      #
      if el.is("[type='text'],textarea")
        el.val()
      else
        el.text()

    compute: (num) ->
      ### Compute lat and lng ###
      #
      #
      Math.round(num * 1000000000) / 1000000000


  class MAPSMODULE.Event
    ### Wrapped ###
    #
    #
    #
    @event: google.maps.event

    @on: (object, event, callback) ->
      ### Event listener ###
      #
      #
      MAPSMODULE.Event.event.addListener object, event, callback


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
      @statues[@directions_status.MAX_WAYPOINTS_EXCEEDED] = '経由点がが多すぎます。経由点は 8 以内です'
      @statues[@directions_status.NOT_FOUND] = 'いずれかの点が緯度経度に変換できませんでした'
      @statues[@directions_status.OVER_QUERY_LIMIT] = '単位時間当りのリクエスト制限回数を超えました'
      @statues[@directions_status.REQUEST_DENIED] = 'このサイトからはルートサービスを使用できません'
      @statues[@directions_status.UNKNOWN_ERROR] = '不明なエラーです。もう一度試すと正常に処理される可能性があります'
      @statues[@directions_status.ZERO_RESULTS] = 'ルートを見つけられませんでした'

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
      # Set options
      if options isnt null then @set_options @check_options(options)
      @set_newobj new @directions_service()
      @status = new @status()

    check_options: (options) ->
      ### Check options ###
      #
      #

      # Valiable
      travelmode = google.maps.DirectionsTravelMode

      if not options.travelMode
        # Driving
        #
        #
        options.travelMode = @options.travelMode

      else if options.travelMode is travelmode.TRANSIT
        # Transit
        #
        #  .. TODO:: Transit is beta.
        #

        # TODO: User input
        d = new Date()
        # 1 hour
        d.setTime new Date().getTime() + (60 * 60 * 1000)

        options.travelMode = travelmode.TRANSIT
        options.transitOptions = departureTime: d
        options.unitSystem = google.maps.UnitSystem.IMPERIAL

      else if options.travelMode is travelmode.BICYCLING
        # BICYCLING
        #
        # .. TODO:: Error
        #
        #
        console.log travelmode.BICYCLING

      else if options.travelMode is travelmode.WALKING
        # WALKING
        #
        #  .. TODO:: Walkng is beta.
        #
        console.log travelmode.WALKING

      options

    _route: (callback, options=@options) ->
      ### Request route ###
      #
      #
      self = @
      options = @check_options options

      # For Beta.
      if @correspond_beta_for_transit options
        @get_newobj().route options, (response, status) ->
          if status is google.maps.DirectionsStatus.OK
            st =
              status: status
              message: ''
              bool: true
          else
            status_ = "Directions Service Error: #{status}"
            message_ = "\n#{self.status.get_message status}"
            st =
              status: status_
              message: message_
              bool: false

          # Call
          callback response, st

    route: (options=@options, callback) ->
      ### Request route ###
      #
      #
      @_route callback, @check_options(options)

    correspond_beta_for_transit: (options=@options) ->
      ### For transit ###
      #
      #
      if @options.travelMode is google.maps.DirectionsTravelMode.TRANSIT
        if window.confirm """
          交通機関は現在Beta版のため提供しているAPIが不完全です
          「OK」を選択すると引続きGoogleMaps上で検索します

              https://maps.google.comで検索しますか？
          """
          url ="https://maps.google.co.jp/maps?saddr=#{options.origin}&daddr=#{options.destination}&hl=ja&ie=UTF8&sll=35.706586,139.767723&sspn=0.040633,0.076818&ttype=now&noexp=0&noal=0&sort=def&mra=ltm&t=m&z=13&start=0"
          w = window.open()
          w.location.href = url
          return no
      yes

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
        @set_results results
        m = if status is @status.OK then "ok" else "Geocode was not successful for the following reason: #{status}"
        callback results, status, m

    set_results: (@results) ->
      ### Set Geocorder result ###
      #
      #

    get_results: ->
      ### Result all ###
      #
      #
      @results

    get_current_location: ->
      ### Current location ###
      #
      #
      @results[0].geometry.location


  class MAPSMODULE.Geolocation extends MAPSMODULE.BaseClass
    ### Wrapped geo ###
    #
    #
    #
    result: null

    options:
      maximumAge: 0
      timeout: 2000
      enableHighAccuracy: true

    constructor: (options=null, @geolocation=@get_geo()) ->
      ### Initializer ###
      #
      #

      # Set options
      if options isnt null then @set_options options

    check_geo: ->
      ### Checker ###
      #
      #
      if navigator.geolocation then true else false

    get_result: () ->
      ### ###
      #
      #
      @result

    set_result: (@result) ->
      ### ###
      #
      #

    get_geo: ->
      ### Getter ###
      #
      #
      if @check_geo() then navigator.geolocation else null

    get_current_location: (callback) ->
        ### Using watchPosition api.

        @param {Function} callback

        ###
        #
        #
        if @check_geo() is false
          console.log "[Geolocation.get_current_location] Location error: Disabled navigator.geolocation."
          return false

        self = @
        calcs = []
        WAIT = 5000

        # Watch
        watch_id = @get_geo().watchPosition (position) ->
          calcs.push {success: position}
        , (error) ->
          calcs.push {error: error}
        , @get_options()

        setTimeout ->
          # Stop watchPosition
          self.get_geo().clearWatch watch_id

          # For calc
          r = self.calc_location calcs

          # CaLL
          callback r, r.status

        , WAIT

    calc_location: (calcs) ->
      ### Calc  ###
      #
      #
      r =
        status: false
        coords: accuracy: 1000

      for calc in calcs
        if calc.success
          # For success
          if calc.success.coords.accuracy < r.coords.accuracy
            # Put Succes object
            r = calc.success
            r.status = true
        else if r.status is false
          # Error re:calc
          r = calc.error
          r.status = false
          r.coords = accuracy: 1000

      @set_result r
      r

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

    el: null

    options:
      el_name: '#info_window'
      map: null
      marker: null
      title: null
      body: null

    default_template: """
    <div class="">
      <div class="modal-header modal-header-wrapper">
        <h3>{title}</h3>
      </div>
      <div class="modal-body">
        <span>{body}</span>
      </div>
    </div>
    """

    constructor: (options=null, @infowindow=google.maps.InfoWindow) ->
      ### Initializer ###
      #
      #

      # Set el
      @el = if options.el_name then $ options.el_name else $('')

      # Set options
      if options isnt null then @set_options options

      # Set new obj
      @set_newobj @get_new()

    get_new: ->
      ### Get new object ###
      #
      #
      new @infowindow()

    get_content: (title, body) ->
      ### ###
      #
      #
      newinfo = @get_newobj() or @get_new()
      newinfo.setContent @render_template(title, body)
      newinfo

    get_template: () ->
      ### Get default template or Element ###
      #
      #
      if @el.is '*'
        @el.html()
      else
        @default_template

    render_template: (title=null, body=null) ->
      ### ###
      #
      #
      t = @get_template()
      t = t.replace '{title}', title or @options?.title
      t = t.replace '{body}', body or @options?.body
      t

    open: (title, body, map=@options.map, marker=@options.marker) ->
      ### Open info window ###
      #
      #
      info = @get_content title, body
      info.open map, marker
      info


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

      # Checking option
      @check_options()

    check_options: () ->
      ### Checking option ###
      #
      #
      console.log "[MAP.check_options] Option error: options.center is #{@options.center}" if not @options.center
      console.log "[MAP.check_options] Option error: options.zoom is #{@options.zoom}" if not @options.zoom

    get_newobj: () ->
      ### Get newobj ###
      #
      #
      @check_options()
      @newobj

    set_center: (latlng) ->
      ### Google latlng object ###
      #
      # @param {Google.maps.LatLng} latlng
      #
      @set_options center: latlng
      @get_newobj().setCenter latlng
      @check_options()

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

    get_body: ->
      ### Title ###
      #
      #
      @el.attr 'body'

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
      # TODO: Bugfix
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
        value: true
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
      tab:
        show: '#tab_show'
        hide: '#tab_hide'
        direct: '#tab_direct'
        control: '#tab_control'
        info: '#tab_info'
      location:
        current: "#location_current"
      travelmode:
        group: '#travelmode-group'
        # drive:
        # bicycle: ''
        # transit: ''
        # walk: ''
      erralert: '#erralert'
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

          options:
            focus:
              input: true
              value: true
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
            tab:
              direct: '#tab_direct'
              control: '#tab_control'
              info: '#tab_info'
              show: '#tab_show'
              hide: '#tab_hide'
            location:
              current: "#location_current"
            travelmode:
              group: '#travelmode-group'
              # drive:
              # bicycle: ''
              # transit: ''
              # walk: ''
            erralert: '#erralert'
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
      if @options.focus.value is true then @push_value()

      # Focus input
      if @options.focus.input is true then @focus_input()

      # Add event auto flg
      # @add_events(callback)

      # Show start panel
      @tab_panel()

    tab_panel: ->
      ### On map tab panel ###
      #
      #
      self = @
      op = @get_options()

      $(op.tab.show).on 'click', ->
        $(op.tab.show).addClass "hide"
        $(self.el_name).removeClass "hide"

      $(op.tab.hide).on 'click', ->
        $(self.el_name).addClass "hide"
        $(op.tab.show).removeClass "hide"

    set_selectors: (selectors) ->
      ### Controller selectors ###
      #
      # TODO:
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
      super value, @get_element(key)

    get_value: (key) ->
      ### Get value of a panel ###
      #
      #
      super @get_element(key)

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
      if @is_checked 'start.checked'
        @set_value_tostart latlng
        @next_focus 'start.point'
      else if @is_checked 'end.checked'
        @set_value_toend latlng
        @next_focus 'end.point'
      else if @is_checked 'way.checked'
        @set_value_toway latlng
        @scroll_bottom 'way.point'
      else
        console.log '[RouteControlPanel.set_point] Not checked error.'

    is_checked: (key) ->
      ### Check push value element ###
      #
      #
      elm = @get_element key

      if elm.attr 'checked'
        true
      else if @_push_value_el is null
        false
      else if @_push_value_el.is elm
        true
      else
        false

    scroll_bottom: (key) ->
      ### Scroller ###
      #
      w = @get_element(key)
      w.scrollTop w.prop('scrollHeight')

    show_direct_tab: () ->
      ### Show tabs ###
      #
      #
      @show_tab @options.tab.direct

    show_control_tab: () ->
      ### Show tabs ###
      #
      #
      @show_tab @options.tab.control

    show_tab: (anchor) ->
      ### Show tabs ###
      #
      #
      $tab = $("[data-toggle='tab'][href='#{anchor}']")
      $.Event("click").preventDefault()
      $tab.click()

    ### Current fucus element ###
    #
    #
    _push_value_el: null

    next_focus: (key) ->
      ### Next focus for input text ###
      #
      #
      self = @
      if @options.focus.next
        @get_element(
          if key is "start.point"
            "end.checked"
          else if key is "end.point"
            "way.checked"
        ).attr('checked', true)
        @get_element(
          if key is "start.point"
            "end.point"
          else if key is "end.point"
            "way.point"
        ).focus ->
          self._push_value_el = $ @

    push_value: ->
      ### Set current focus ###
      #
      #
      self = @
      @get_element('start.point').focus(-> self._push_value_el = $ @).blur -> self._push_value_el = null
      @get_element('end.point').focus(-> self._push_value_el = $ @).blur -> self._push_value_el = null
      @get_element('way.point').focus(-> self._push_value_el = $ @).blur -> self._push_value_el = null

    focus_input: ->
      ### Set current focus ###
      #
      #
      self = @
      @get_element('start.point').focus -> self.get_element('start.checked').attr 'checked', true
      @get_element('end.point').focus -> self.get_element('end.checked').attr 'checked', true
      @get_element('way.point').focus -> self.get_element('way.checked').attr 'checked', true

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
      $(object.id).on object.event, {maincallback: object.callback.main, usercallback: object.callback.user}, object.method

    add_route_event: (callback) ->
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
          event: @_get_objkey route.event
          method: @on_route
          callback:
            main: callback
            user: @_get_objvalue route.event

    add_clearaddr_event: (callback) ->
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
          event: @_get_objkey clearaddr.event
          method: @on_clearaddr
          callback:
            main: callback
            user: @_get_objvalue clearaddr.event

    get_travelmode: () ->
      ### Get travelmode ###
      #
      #
      @get_element('travelmode.group').find('.active').val()

    show_error: (message, status) =>
      ### Show message ###
      #
      #
      alt = @get_element('erralert')
      alt.find('strong').text status
      alt.find('span').text message
      alt.show()
      alt.find('.close').off("click").on "click", (e) ->
        $(@).parent().hide()

    on_clearaddr: (event) =>
      ### Clear form  ###
      #
      #
      @set_value 'start.point', ''
      @set_value 'end.point', ''
      @set_value 'way.point', ''
      @get_element('start.checked').attr 'checked', true
      @get_element('way.nonhighway').attr 'checked', false
      @get_element('way.nontollway').attr 'checked', false

      # Calls
      event.data?.usercallback event, @
      event.data?.maincallback event, @

    on_route: (event) =>
      ### Route search request ###
      #
      #

      # Start
      start = @get_value 'start.point'
      # End
      end = @get_value 'end.point'
      # Non highway
      hw = if @get_element("way.nonhighway").attr 'checked' then true else false
      # Non tollway
      toll = if @get_element("way.nontollway").attr 'checked' then true else false
      # Mode
      mode = @get_travelmode()
      # Way point
      waypts = []
      for wats in @get_value("way.point").split "\n"
        if wats != '' then waypts.push {location: wats, stopover: true}

      # Add parameter
      event.data.control_panel =
        options: {start, end, hw, toll, mode, waypts}

      # Calls
      event.data?.usercallback event, @
      event.data?.maincallback event, @

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

    ### Geolocation object ###
    #
    #
    geolocation: MAPSMODULE.Geolocation

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

      # new
      @set_option_class options, 'geolocation'

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
      new @marker {position: latlng, title, map}

    get_infowindow: (marker, title=@map.get_title(), map=@map.get_newobj()) ->
      ### Open info window ###
      #
      #
      # Get marker object
      marker = marker?.get_newobj() or marker
      new @infowindow {marker, map, title}

    open_infowindow: (marker, title=@map.get_title(), body=@map.get_body()) ->
      ### ###
      #
      #
      infowindow = @get_infowindow marker
      infowindow.open title, body
      infowindow

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
        @direct_render.set_panel direct_panel_el.get(0)
      else
        console.log "[RenderRouteMap.set_direct_panel] Arguments error: (direct_panel_el is #{direct_panel_el})"

    run: (options={}) ->
      ### Render map ###
      #
      #
      @get_latlng options?.place, (results, status, message) =>
        ### Current latlng ###
        #
        #

        # Set latlng object
        @map.set_center @geocorder.get_current_location()

        # Set map to panel.
        @set_map()

        # Set directions panel
        @set_direct_panel()

        # New marker
        marker = @get_marker @geocorder.get_current_location()

        # New infowindow
        infowindow = @open_infowindow marker

        ### Event receivers ###
        #
        #

        @control_panel.add_clearaddr_event (event, cls) =>
          ### On submit clear input values. ###
          #
          #

        @control_panel.add_route_event (event, cls) =>
          ### On submit route search ###
          #
          #
          options = event.data.control_panel.options
          service = new @direct_service
            origin: options.start
            destination: options.end
            waypoints: options.waypts
            optimizeWaypoints: true
            avoidHighways: options.hw
            avoidTolls: options.toll
            travelMode: options.mode

          service._route (response, status) =>
            ### Request calc route ###
            #
            #
            if status.bool
              @control_panel.show_direct_tab()
              @direct_render.set_directions response
              @info_panel.set_total_distance response
            else
              @control_panel.show_error status.message, status.status

        @event.on marker.get_newobj(), 'click', (event) =>
          ### Mouse event receiver ###
          #
          #
          @open_infowindow marker

        @event.on @map.get_newobj(), 'click', (event) =>
          ### Mouse event receiver ###

          #
          @control_panel.show_control_tab()
          @control_panel.set_point event.latLng, @map.get_newobj()

        @event.on @direct_render.get_newobj(), 'click', (event) =>
          ### Directions changed event receiver ###
          #
          #
          newobj = @direct_render.get_newobj()

          @direct_panel.set_total_distance newobj.directions, newobj
          @info_panel.set_total_distance newobj.directions, newobj


  MAPSMODULE
