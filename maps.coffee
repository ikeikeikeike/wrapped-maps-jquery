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


  MAPSMODULE.moduleChecker = ->
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

  if MAPSMODULE.moduleChecker() is false then return MAPSMODULE

  class MAPSMODULE.BaseClass
    ### Common methods ###
    #
    #

    ### New object ###
    #
    #
    newobj: null

    getOptions: ->
      ### Get options ###
      #
      #
      @options

    setOptions: (objects) ->
      ### Set options by objects ###
      #
      #
      for key, value of objects
        @options[key] = value

    getNewobj: ->
      ### Get new object ###
      #
      #
      @newobj

    setNewobj: (@newobj) ->
      ### Set new object ###
      #
      #

    setValue: (value, el=@el) ->
      ### Set value to a dom ###
      #
      #
      if el.is("[type='text'],textarea")
        el.val value
      else
        el.text value

    getValue: (el=@el) ->
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
    # .. Response status of Direction service ::
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

    constructor: (@directionsStatus=google.maps.DirectionsStatus) ->
      ### Initializer ###
      #
      #
      @statues[@directionsStatus.INVALID_REQUEST] = 'DirectionsRequest が無効'
      @statues[@directionsStatus.MAX_WAYPOINTS_EXCEEDED] = '経由点がが多すぎます。経由点は 8 以内です'
      @statues[@directionsStatus.NOT_FOUND] = 'いずれかの点が緯度経度に変換できませんでした'
      @statues[@directionsStatus.OVER_QUERY_LIMIT] = '単位時間当りのリクエスト制限回数を超えました'
      @statues[@directionsStatus.REQUEST_DENIED] = 'このサイトからはルートサービスを使用できません'
      @statues[@directionsStatus.UNKNOWN_ERROR] = '不明なエラーです。もう一度試すと正常に処理される可能性があります'
      @statues[@directionsStatus.ZERO_RESULTS] = 'ルートを見つけられませんでした'

    getMessage: (status) ->
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

    constructor: (@panelName, options=null, @directionsRenderer=google.maps.DirectionsRenderer) ->
      ### Initializer ###
      #
      #

      # Set options
      if options isnt null then @setOptions options
      @setNewobj new @directionsRenderer(@options)
      @setPanel @panelName

    setMap: (map) ->
      ### Set map object. ###
      #
      #
      @getNewobj().setMap map

    setPanel: (panelName=@panelName) ->
      ### Set panel by element name. ###
      #
      #
      @getNewobj().setPanel panelName

    setDirections: (results) ->
      ### Set response results of directionsService.route ###
      #
      #
      @getNewobj().setDirections results


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

    constructor: (options=null, @directionsService=google.maps.DirectionsService, @status=MAPSMODULE.DirectionsStatue) ->
      ### Initializer ###
      #
      #
      # Set options
      if options isnt null then @setOptions @checkOptions(options)
      @setNewobj new @directionsService()
      @status = new @status()

    checkOptions: (options) ->
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

        # TODO: Set input vlaue of date by user.
        #
        d = new Date()
        # 1 hour
        d.setTime new Date().getTime() + (60 * 60 * 1000)

        options.travelMode = travelmode.TRANSIT
        options.transitOptions = departureTime: d
        options.unitSystem = google.maps.UnitSystem.IMPERIAL

      else if options.travelMode is travelmode.BICYCLING
        # BICYCLING
        #
        # .. TODO:: Now errorful.
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
      options = @checkOptions options

      # For Beta.
      if @correspondBetaForTransit options
        @getNewobj().route options, (response, status) ->
          if status is google.maps.DirectionsStatus.OK
            st =
              status: status
              message: ''
              bool: true
          else
            status_ = "Directions Service Error: #{status}"
            message_ = "\n#{self.status.getMessage status}"
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
      @_route callback, @checkOptions(options)

    correspondBetaForTransit: (options=@options) ->
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
      @setNewobj new @geocoder()

    addressToLatlng: (address, callback) ->
      ### Convert from address to latlng ###
      #
      #
      @getNewobj().geocode {'address': address}, (results, status) =>
        @setResults results
        m = if status is @status.OK then "ok" else "Geocode was not successful for the following reason: #{status}"
        callback results, status, m

    setResults: (@results) ->
      ### Set result of Geocoder to this object ###
      #
      #

    getResults: ->
      ### Result all ###
      #
      #
      @results

    getCurrentLocation: ->
      ### Current location ###
      #
      #
      @results[0].geometry.location


  class MAPSMODULE.Geolocation extends MAPSMODULE.BaseClass
    ### Wrapped geo ###
    #
    #
    result: null

    options:
      maximumAge: 0
      timeout: 2000
      enableHighAccuracy: true

    constructor: (options=null, @geolocation=@getGeo()) ->
      ### Initializer ###
      #
      #

      # Set options
      if options isnt null then @setOptions options

    checkGeo: ->
      ### Checker ###
      #
      #
      if navigator.geolocation then true else false

    getResult: ->
      ### ###
      #
      #
      @result

    setResult: (@result) ->
      ### ###
      #
      #

    getGeo: ->
      ### Getter ###
      #
      #
      if @checkGeo() then navigator.geolocation else null

    getCurrentLocation: (callback) ->
        ### Using watchPosition api.

        @param {Function} callback

        .. note ::

            Using watchPosition api.

        ###
        #
        #
        if @checkGeo() is false
          console.log "[Geolocation.getCurrentLocation] Location error: Disabled navigator.geolocation."
          return false

        self = @
        calcs = []
        WAIT = 5000

        # Watch
        watchId = @getGeo().watchPosition (position) ->
          calcs.push {success: position}
        , (error) ->
          calcs.push {error: error}
        , @getOptions()

        setTimeout ->
          # Stop watchPosition
          self.getGeo().clearWatch watchId

          # Calculate position object
          r = self.calcLocation calcs

          # CaLL
          callback r, r.status

        , WAIT

    calcLocation: (calcs) ->
      ### Calculate position object

      @param {Array<Object>} calcs
      @return {Object}

      ###
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

      @setResult r
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
      @setNewobj @getNew()

    getNew: (options=@options) ->
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
      elName: '#info_window'
      map: null
      marker: null
      title: null
      body: null

    defaultTemplate: """
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
      @el = if options.elName then $ options.elName else $('')

      # Set options
      if options isnt null then @setOptions options

      # Set new obj
      @setNewobj @getNew()

    getNew: ->
      ### Get new object ###
      #
      #
      new @infowindow()

    getContent: (title, body) ->
      ### ###
      #
      #
      newinfo = @getNewobj() or @getNew()
      newinfo.setContent @renderTemplate(title, body)
      newinfo

    getTemplate: ->
      ### Get default template or specific element ###
      #
      #
      if @el.is '*'
        @el.html()
      else
        @defaultTemplate

    renderTemplate: (title=null, body=null) ->
      ### ###
      #
      #
      t = @getTemplate()
      t = t.replace '{title}', title or @options?.title
      t = t.replace '{body}', body or @options?.body
      t

    open: (title, body, map=@options.map, marker=@options.marker) ->
      ### Open info window ###
      #
      #
      info = @getContent title, body
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

    constructor: (@elName='#googlemaps', options=null, @map=google.maps.Map) ->
      ### Initializer ###
      #
      #
      # Set element
      @el = $ @elName

      # Set options
      if options isnt null then @setOptions options

      # New object
      @setNewobj @getNew()

      # Checking option
      @checkOptions()

    checkOptions: ->
      ### Checking option ###
      #
      #
      console.log "[MAP.checkOptions] Option error: options.center is #{@options.center}" unless @options.center
      console.log "[MAP.checkOptions] Option error: options.zoom is #{@options.zoom}" unless @options.zoom

    getNewobj: ->
      ### Get newobj ###
      #
      #
      @checkOptions()
      @newobj

    setCenter: (latlng) ->
      ### Google latlng object ###
      #
      # @param {Google.maps.LatLng} latlng
      #
      @setOptions center: latlng
      @getNewobj().setCenter latlng
      @checkOptions()

    getNew: (el=@el, options=@options) ->
      ### Get new map object ###
      #
      #
      new @map el.get(0), options

    getAddress: ->
      ### Address ###
      #
      #
      @el.attr 'address'

    getTitle: ->
      ### Title ###
      #
      #
      @el.attr 'title'

    getBody: ->
      ### Title ###
      #
      #
      @el.attr 'body'

    getContent: ->
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

    constructor: (@elName='#info_panel') ->
      ### Initializer ###
      #
      #
      @el = $ @elName

    setTotalDistance: (results, object) ->
      ### Set total distance ###
      #
      # TODO: Bugfix
      #
      data = ''
      for routes in results.routes
        for overview_path in routes.overview_path
          data += "#{@compute overview_path.lng()},#{@compute overview_path.lat()}\n"
      @setValue data


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

    constructor: (@elName='#directions_panel', options=null) ->
      ### Initializer
      @param {String} elName - Top element name.
      @param {Object} options - options.

      .. Options, e.g. ::

          options =
            total: '#total'
      ###
      #
      #
      @el = $ @elName

    setTotalDistance: (results, object) ->
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

    constructor: (@elName='#control_panel', options=null) ->
      ### Initializer
      @param {String} elName - Top element name.
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
      @el = $ @elName

      # Set controller
      @setSelectors(options or @options)
      # gen html

      # @generateHtml

      # Push latlng value
      if @options.focus.value is true then @pushValue()

      # Focus input
      if @options.focus.input is true then @focusInput()

      #
      # @addEvents(callback)

      # Show start panel


      @tabPanel()

    tabPanel: ->
      ### Event listener ###
      #
      #
      self = @
      op = @getOptions()

      $(op.tab.show).on 'click', ->
        $(op.tab.show).addClass "hide"
        $(self.elName).removeClass "hide"

      $(op.tab.hide).on 'click', ->
        $(self.elName).addClass "hide"
        $(op.tab.show).removeClass "hide"

    setSelectors: (selectors) ->
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

    generateHtml: (selectors) ->
      ### Generate control panel ###
      #
      #

    getSelector: (key) ->
      op = @options
      for i in key.split "."
        op = op[i]
      op

    getElement: (key) ->
      ### ###
      #
      #
      $ @getSelector(key)

    setValue: (key, value) ->
      ### Set value to a panel ###
      #
      #
      super value, @getElement(key)

    getValue: (key) ->
      ### Get value of a panel ###
      #
      #
      super @getElement(key)

    setValueTostart: (value) ->
      ### ###
      #
      #
      @setValue 'start.point', value

    setValueToend: (value) ->
      ### ###
      #
      #
      @setValue 'end.point', value

    setValueToway: (value) ->
      ### ###
      #
      #
      @setValue 'way.point', "#{@getValue 'way.point'}#{value}\n"

    setPoint: (latlng, object=null) ->
      ### Set latLng to dom and next focus. ###
      #
      #
      if @isChecked 'start.checked'
        @setValueTostart latlng
        @nextFocus 'start.point'
      else if @isChecked 'end.checked'
        @setValueToend latlng
        @nextFocus 'end.point'
      else if @isChecked 'way.checked'
        @setValueToway latlng
        @scrollBottom 'way.point'
      else
        console.log '[RouteControlPanel.setPoint] Not checked error.'

    isChecked: (key) ->
      ### Check push value element ###
      #
      #
      elm = @getElement key

      if elm.attr 'checked'
        true
      else if @_pushValueEl is null
        false
      else if @_pushValueEl.is elm
        true
      else
        false

    scrollBottom: (key) ->
      ### Scroller ###
      #
      w = @getElement(key)
      w.scrollTop w.prop('scrollHeight')

    showDirectTab: ->
      ### Show tabs ###
      #
      #
      @showTab @options.tab.direct

    showControlTab: ->
      ### Show tabs ###
      #
      #
      @showTab @options.tab.control

    showTab: (anchor) ->
      ### Show tabs ###
      #
      #
      $tab = $("[data-toggle='tab'][href='#{anchor}']")
      $.Event("click").preventDefault()
      $tab.click()

    ### Current fucus element ###
    #
    #
    _pushValueEl: null

    nextFocus: (key) ->
      ### Next focus for input text ###
      #
      #
      self = @
      if @options.focus.next
        @getElement(
          if key is "start.point"
            "end.checked"
          else if key is "end.point"
            "way.checked"
        ).attr('checked', true)
        @getElement(
          if key is "start.point"
            "end.point"
          else if key is "end.point"
            "way.point"
        ).focus ->
          self._pushValueEl = $ @

    pushValue: ->
      ### Set current focus ###
      #
      #
      self = @
      @getElement('start.point').focus(-> self._pushValueEl = $ @).blur -> self._pushValueEl = null
      @getElement('end.point').focus(-> self._pushValueEl = $ @).blur -> self._pushValueEl = null
      @getElement('way.point').focus(-> self._pushValueEl = $ @).blur -> self._pushValueEl = null

    focusInput: ->
      ### Set current focus ###
      #
      #
      self = @
      @getElement('start.point').focus -> self.getElement('start.checked').attr 'checked', true
      @getElement('end.point').focus -> self.getElement('end.checked').attr 'checked', true
      @getElement('way.point').focus -> self.getElement('way.checked').attr 'checked', true

    _getObjkey: (object) ->
      ### For one object ###
      #
      #
      (k for k, v of object)[0]

    _getObjvalue: (object) ->
      ### For one object ###
      #
      #
      (v for k, v of object)[0]

    on: (object=null) ->
      ### Utility ###
      #
      #
      $(object.id).on object.event, {maincallback: object.callback.main, usercallback: object.callback.user}, object.method

    addRouteEvent: (callback) ->
      ### Add events listener ###
      #
      # Route event
      #
      if not @options.event
        @on
          id: @options.event.route
          event: 'click'
          method: @onRoute
          callback:
            main: callback
            user: null
      else
        route = @options.event.route
        @on
          id: route.id
          event: @_getObjkey route.event
          method: @onRoute
          callback:
            main: callback
            user: @_getObjvalue route.event

    addClearaddrEvent: (callback) ->
      ### Add events listener ###
      #
      # ClearAddress event
      #
      if not @options.event
        @on
          id: @options.event.clearaddr
          event: 'click'
          method: @onClearaddr
          callback:
            main: callback
            user: null
      else
        clearaddr = @options.event.clearaddr
        @on
          id: clearaddr.id
          event: @_getObjkey clearaddr.event
          method: @onClearaddr
          callback:
            main: callback
            user: @_getObjvalue clearaddr.event

    getTravelmode: ->
      ### Get travelmode ###
      #
      #
      @getElement('travelmode.group').find('.active').val()

    showError: (message, status) =>
      ### Show message ###
      #
      #
      alt = @getElement('erralert')
      alt.find('strong').text status
      alt.find('span').text message
      alt.show()
      alt.find('.close').off("click").on "click", (e) ->
        $(@).parent().hide()

    hideError: =>
      ### Hide message ###
      #
      #
      alt = @getElement('erralert')
      alt.find('strong').text ''
      alt.find('span').text ''
      alt.hide()

    onClearaddr: (event) =>
      ### Clear form  ###
      #
      #
      @setValue 'start.point', ''
      @setValue 'end.point', ''
      @setValue 'way.point', ''
      @getElement('start.checked').attr 'checked', true
      @getElement('way.nonhighway').attr 'checked', false
      @getElement('way.nontollway').attr 'checked', false

      # Calls
      event.data?.usercallback event, @
      event.data?.maincallback event, @

    onRoute: (event) =>
      ### Route search request ###
      #
      #

      # Start
      start = @getValue 'start.point'
      # End
      end = @getValue 'end.point'
      # Non highway
      hw = if @getElement("way.nonhighway").attr 'checked' then true else false
      # Non tollway
      toll = if @getElement("way.nontollway").attr 'checked' then true else false
      # Mode
      mode = @getTravelmode()
      # Way point
      waypts = []
      for wats in @getValue("way.point").split "\n"
        if wats != '' then waypts.push {location: wats, stopover: true}

      # Add parameter
      event.data.controlPanel =
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
    controlPanel: MAPSMODULE.RouteControlPanel

    ### Result panel ###
    #
    #
    directPanel: MAPSMODULE.RouteDirectionsPanel

    ### Info panel ###
    #
    #
    infoPanel: MAPSMODULE.RouteInfoPanel

    ### Direction Renderer object ###
    #
    #
    directRender: MAPSMODULE.DirectionsRenderer

    ### Direction Service object ###
    #
    #
    directService: MAPSMODULE.DirectionsService

    ### Map object ###
    #
    # @param {google.maps.DirectionsService}
    #
    map: MAPSMODULE.Map

    ### Marker object ###
    #
    # @param {google.maps.Map}
    #
    marker: MAPSMODULE.Marker

    ### InfoWindow object ###
    #
    # @param {google.maps.InfoWindow}
    #
    infowindow: MAPSMODULE.InfoWindow

    ### Event object ###
    #
    # @param {google.maps.event}
    #
    event: MAPSMODULE.Event

    ### Geocorder object ###
    #
    # @param {google.maps.Geocorder}
    #
    geocorder: MAPSMODULE.Geocorder

    ### Geolocation object ###
    #
    # @param {navigator.geolocation}
    #
    geolocation: MAPSMODULE.Geolocation

    constructor: (options=null) ->
      ### Initializer
      @param {String|Object} place - Address{String} or Google latlng{Object}.
      @param {Object} options - Options for rendering map.

      .. Options, e.g. ::

          options =
            directPanel:
              obj: new RouteDirectionsPanel("#directions_panel")
              name: '#directions_panel'
              options: null
            controlPanel:
              obj: new RouteControlPanel("#control_panel")
              name: '#direct_panel'
              options: {}
            infoPanel:
              obj: new RouteInfoPanel("#info_panel")
              name: '#info_panel'
              options: {}
            directRender:
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

      ## Set objects to this property.
      #
      # Set directPanel
      @setOptionClass options, 'directPanel'

      # Set control panel to this property.
      @setOptionClass options, 'controlPanel'

      # Set infoPanel
      @setOptionClass options, 'infoPanel'

      # Set directions renderer
      @setOptionClass options, 'directRender'

      # {google.maps.Map}
      @setOptionClass options, 'map'

      # {google.maps.Geocorder}
      @setOptionClass options, 'geocorder'

      # Geolocation
      @setOptionClass options, 'geolocation'

      # My options
      @place = options?.place

    setOptionClass: (options, key) ->
      ### Set class to property ###
      #
      #
      # Set options.key to property.
      objs = options?[key]

      objsObj = objs?.obj || null
      if objsObj isnt null
        @[key] = objsObj
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

    getLatlng: (place=@place, callback) ->
      ### Get latlng ###
      #
      #
      @geocorder.addressToLatlng place or @map.getAddress(), (results, status, message) ->
        callback results, status, message

    getMarker: (latlng, title=@map.getTitle(), map=@map.getNewobj()) ->
      ### Get marker object ###
      #
      #
      new @marker {position: latlng, title, map}

    getInfowindow: (marker, title=@map.getTitle(), map=@map.getNewobj()) ->
      ### Open info window ###
      #
      #
      # Get marker object
      marker = marker?.getNewobj() or marker
      new @infowindow {marker, map, title}

    openInfowindow: (marker, title=@map.getTitle(), body=@map.getBody()) ->
      ### ###
      #
      #
      infowindow = @getInfowindow marker
      infowindow.open title, body
      infowindow

    setMap: (map=@map.getNewobj()) ->
      ### Set map ###
      #
      #
      @directRender.setMap map

    setDirectPanel: (directPanelEl=@directPanel.el) ->
      ### Set panel ###
      #
      #
      if directPanelEl.is '*'
        @directRender.setPanel directPanelEl.get(0)
      else
        console.log "[RenderRouteMap.setDirectPanel] Arguments error: (directPanelEl is #{directPanelEl})"

    run: (options={}) ->
      ### Render map ###
      #
      #
      @getLatlng options?.place, (results, status, message) =>
        ### Current latlng ###
        #
        #

        # Set latlng to a map options.
        @map.setCenter @geocorder.getCurrentLocation()

        # Set map to panel
        @setMap()

        # Set directions panel
        @setDirectPanel()

        # New marker
        marker = @getMarker @geocorder.getCurrentLocation()

        # New infowindow
        infowindow = @openInfowindow marker

        ### Event receivers ###
        #
        #

        @controlPanel.addClearaddrEvent (event, cls) =>
          ### On submit clear input values. ###
          #
          #

        @controlPanel.addRouteEvent (event, cls) =>
          ### On submit route search ###
          #
          #
          options = event.data.controlPanel.options
          service = new @directService
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
              @controlPanel.showDirectTab()
              @directRender.setDirections response
              @infoPanel.setTotalDistance response
              @controlPanel.hideError()
            else
              @controlPanel.showError status.message, status.status

        @event.on marker.getNewobj(), 'click', (event) =>
          ### Mouse event receiver ###
          #
          #
          @openInfowindow marker

        @event.on @map.getNewobj(), 'click', (event) =>
          ### Mouse event receiver ###

          #
          @controlPanel.showControlTab()
          @controlPanel.setPoint event.latLng, @map.getNewobj()

        @event.on @directRender.getNewobj(), 'click', (event) =>
          ### Directions changed event receiver ###
          #
          #
          newobj = @directRender.getNewobj()

          @directPanel.setTotalDistance newobj.directions, newobj
          @infoPanel.setTotalDistance newobj.directions, newobj

        # TODO: Next impl
        # google.maps.event.addListener(directionsDisplay, 'directions_changed', function() {
          # computeTotalDistance(directionsDisplay.directions);
        # })


  MAPSMODULE
