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
      $ "html"
    catch error
      console.log "[wrapped-maps-jquery] Required module error: #{error}, Required module in maps.js."
      return no
    yes

  if MAPSMODULE.moduleChecker() is no then return MAPSMODULE

  ### Utility ###
  #
  String.prototype.capitalize = ->
    ###
    .. e.g. ::

      "hello world".capitalize();  =>  "Hello world"
    ###
    @charAt(0).toUpperCase() + @slice(1)


  class MAPSMODULE.BaseClass
    ### Common Mixin ###
    #

    ### A property passed through constructor ###
    #
    # .. note:: XXX
    #
    newobj: null

    getOptions: ->
      ### XXX:

      @return {Object}
      ###
      @options

    setOptions: (objects) ->
      ### Set options by objects

      @param {Object} objects
      ###
      for key, value of objects
        @options[key] = value

    getNewobj: ->
      ### XXX: ###
      #
      @newobj

    setNewobj: (@newobj) ->
      ### XXX:

      @pparam {Object} newobj
      ###

    setValue: (value, el=@el) ->
      ### Set value to a dom ###
      #
      # @param {String} value
      # @param {jQuery.Element} el
      #
      if el.is("[type='text'],textarea")
        el.val value
      else
        el.text value

    getValue: (el=@el) ->
      ### Get value of a dom ###
      #
      if el.is("[type='text'],textarea")
        el.val()
      else
        el.text()

    getSelector: (key) ->
      ### From options.key ###
      #
      op = @getOptions()
      for i in key.split "."
        op = op[i]
      op

    getElement: (key) ->
      ### XXX: ###
      #
      $ @getSelector(key)

    _getObjkey: (object) ->
      ### For one object ###
      #
      (k for k, v of object)[0]

    _getObjvalue: (object) ->
      ### For one object ###
      #
      (v for k, v of object)[0]

    on: (object=null) ->
      ### Utility ###
      #
      $(object.id).on object.event, {maincallback: object.callback.main, usercallback: object.callback.user}, object.method

    compute: (num) ->
      ### Compute lat and lng ###
      #
      Math.round(num * 1000000000) / 1000000000


  class MAPSMODULE.BaseApi extends MAPSMODULE.BaseClass
    ### Common class ###
    #

    options:
      baseurl: ''
      format: 'json'

    path_join: (list) ->
      ### XXX: ###
      #
      (s.replace(/^\/|\/$/g, '') for s in list when s).join '/'

    url: (path) ->
      ### Generate to apiurl ###
      #
      @path_join [@options.baseurl, path]

    toQueryString: (data) ->
      ### Convert from obj to string ###
      #
      str = []
      for key, value of obj
        str.push(encodeURIComponent key + "=" + encodeURIComponent value)
      str.join "&"
      str

    commonCallback: (json, callback, status, message) ->
      ### Callback function ###
      #
      # console.log json, callback
      callback?(json, status, message)

    get: (url, callback) =>
      ### XXX: ###
      #
      $.getJSON @url(url), (arrayobj) =>
        @commonCallback arrayobj, callback

    post: (url, data, callback, format='json') ->
      ### This function is like a getJSON for POST method ###
      #
      # formats::
      #
      #   json, html
      #
      $.post @url(url), data, (response) =>
        @commonCallback response, callback
      , @options.format


  class MAPSMODULE.Event extends MAPSMODULE.BaseClass
    ### Wrapped ###
    #
    @event: google.maps.event

    @on: (object, event, callback) ->
      ### Utility ###
      #
      MAPSMODULE.Event.event.addListener object?.getNewobj?() or object, event, callback


  class MAPSMODULE.DirectionsStatue extends MAPSMODULE.BaseClass
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
      ### XXX: ###
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
      @statues[status]


  class MAPSMODULE.DirectionsRenderer extends MAPSMODULE.BaseClass
    ### Wrapping XXX: ###
    #

    ### Render options ###
    #
    options:
      draggable: yes

    constructor: (@panelName, options=null, @directionsRenderer=google.maps.DirectionsRenderer) ->
      ### XXX: ###
      #

      if options isnt null then @setOptions options
      @setNewobj new @directionsRenderer(@options)
      @setPanel @panelName

    setMap: (map) ->
      ###

      @param {MAPSMODULE.Map|google.maps.Map} map
      ###
      @getNewobj().setMap map?.getNewobj?() or map

    setPanel: (panelName=@panelName) ->
      ### Set panel by element name

      @param {String} Element selectorname.
      ###
      #
      @getNewobj().setPanel panelName

    setDirections: (results) ->
      ### Set response results of directionsService.route ###
      #
      @getNewobj().setDirections results


  class MAPSMODULE.DirectionsService extends MAPSMODULE.BaseClass
    ### Wrapping class ###
    #

    ### Route options ###
    #
    options:
      origin: ''
      destination: ''
      waypoints: ''
      optimizeWaypoints: yes
      avoidHighways: yes
      avoidTolls: yes
      travelMode: google.maps.DirectionsTravelMode.DRIVING
      # transitOptions: {
        # departureTime: new Date(1337675679473)
      # }
      # travelMode: google.maps.DirectionsTravelMode.TRANSIT
      # unitSystem: google.maps.UnitSystem.IMPERIAL

    constructor: (options=null, @directionsService=google.maps.DirectionsService, @status=MAPSMODULE.DirectionsStatue) ->
      ### XXX: ###
      #
      if options isnt null then @setOptions @checkOptions(options)
      @setNewobj new @directionsService()
      @status = new @status()

    checkOptions: (options) ->
      ### Check travelmode, etc ###
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
        console.log "#{travelmode.BICYCLING} is beta."

      else if options.travelMode is travelmode.WALKING
        # WALKING
        #
        #  .. TODO:: Walkng is beta.
        #
        console.log "#{travelmode.WALKING} is beta."

      options

    _route: (callback, options=@options) ->
      ### Request route ###
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
              bool: yes
          else
            status_ = "Directions Service Error: #{status}"
            message_ = "\n#{self.status.getMessage status}"
            st =
              status: status_
              message: message_
              bool: no

          # Call
          callback response, st

    route: (options=@options, callback) ->
      ### Request route ###
      #
      @_route callback, @checkOptions(options)

    correspondBetaForTransit: (options=@options) ->
      ### For transit ###
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

    constructor: (@geocoder=google.maps.Geocoder, @status=google.maps.GeocoderStatus) ->
      ### XXX: ###
      #
      @setNewobj new @geocoder()

    addressToLatlng: (address, callback) ->
      ### Convert from address to latlng ###
      #
      @getNewobj().geocode {'address': address}, (results, status) =>
        @setResults results
        if status is @status.OK
          message = "ok"
        else
          prefix = "[Geocorder.addressToLatlng] "
          message = "Geocode was not successful for the following reason: #{status}"
          console.log "#{prefix} #{message}"
          console.log "#{prefix}Request error: Parameter address is `#{address}`"

        # callback
        callback results, status, message

    setResults: (@results) ->
      ### Set result of Geocoder to this object ###
      #

    getResults: ->
      ### Result all ###
      #
      @results

    getCurrentLocation: ->
      ### Current location  ###
      #
      try
        @results[0].geometry.location
      catch e
        console.log "[Geocorder.getCurrentLocation] #{e}"

  class MAPSMODULE.Geolocation extends MAPSMODULE.BaseClass
    ### Wrapped geo ###
    #
    result: null

    options:
      maximumAge: 0
      timeout: 1500
      frequency: 1000
      enableHighAccuracy: yes

    constructor: (options=null, @geolocation=@getGeo()) ->
      ### XXX: ###
      #

      if options isnt null then @setOptions options

    checkGeo: ->
      ### Checker ###
      #
      #
      if navigator.geolocation then yes else no

    getResult: ->
      ### XXX: ###
      #
      @result

    setResult: (@result) ->
      ### XXX: ###
      #

    getGeo: ->
      ### Getter ###
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
        if @checkGeo() is no
          console.log "[Geolocation.getCurrentLocation] Location error: Disabled navigator.geolocation."
          return no

        self = @
        calcs = []
        WAIT = 3000

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
      r =
        code: 1000
        status: no
        coords: accuracy: 1000

      for calc in calcs
        if calc.success
          # For success
          if calc.success.coords.accuracy < r.coords.accuracy
            # Put Succes object
            r = calc.success
            r.status = yes
        else if r.status is no
          # Error re:calc
          r = calc.error
          r.status = no
          r.coords = accuracy: 1000

      @setResult r
      r

  class MAPSMODULE.Marker extends MAPSMODULE.BaseClass
    ### XXX: ###
    #

    ### XXX: ###
    #
    options:
      position: null
      map: null
      title: null

    constructor: (@options, @marker=google.maps.Marker) ->
      ### XXX:  ###
      #
      @setNewobj @getNew()

    getNew: (options=@options) ->
      ### Get new object ###
      #
      new @marker
        position: options.position?.getNewobj?() or options.position
        map: options.map?.getNewobj?() or options.map
        title: options.title

    setMap: (obj) ->
      @newobj.setMap obj


  class MAPSMODULE.LatLng extends MAPSMODULE.BaseClass
    ### XXX: ###
    #
    #
    constructor: (options=null, @latlng=google.maps.LatLng) ->

    @new: (lat, lng) ->
      ### Utils ###
      #
      #
      obj = new MAPSMODULE.LatLng()
      new obj.latlng(lat, lng)

  class MAPSMODULE.InfoWindow extends MAPSMODULE.BaseClass
    ### Wrapping XXX:  ###
    #
    #

    el: null

    options:
      elName: '#info_window'
      map: null
      marker: null
      title: null
      body: null

    template: null

    defaultTemplate: """
    <div class="">
      <div class="modal-header modal-header-wrapper">
        <h3>{title}</h3>
      </div>
      <div class="modal-body">
        {body}
      </div>
    </div>
    """

    constructor: (options=null, @infowindow=google.maps.InfoWindow) ->
      ### XXX: ###
      #
      #

      # Set el
      @el = if options.elName then $ options.elName else $('')

      if options isnt null then @setOptions options

      @setNewobj @getNew()

    getNew: ->
      ### Get new object ###
      #
      #
      new @infowindow()

    getContent: (title, body, obj) ->
      ### XXX: ###
      #
      #
      newinfo = @getNewobj?() or @getNew()
      newinfo.setContent @renderTemplate(title, body, obj)
      newinfo

    setTemplate: (@template) ->
      ### XXX: ###
      #

    getTemplate: ->
      ### Get default template or specific element ###
      #
      #
      if @el.is '*'
        @el.html()
      else if @template
        @template
      else
        @defaultTemplate

    renderTemplate: (title=null, body=null, obj=null) ->
      ### XXX: ###
      #
      #
      t = @getTemplate()
      if obj
        for key, value of obj
          t = t.split("{#{key}}").join value
          t = t.split("%7B#{key}%7D").join value
      else
        t = t.replace /{title}/g, title or @options?.title
        t = t.replace /{body}/g, body or @options?.body
        t = t.replace /%7Btitle%7D/g, title or @options?.title
        t = t.replace /%7Bbody%7D/g, body or @options?.body
      t

    open: (title, body, map=@options.map, marker=@options.marker) ->
      ### Open info window ###
      #
      #
      info = @getContent title, body
      info.open map?.getNewobj?() or map, marker?.getNewobj?() or marker
      info

    openTemplate: (obj, map=@options.map, marker=@options.marker) ->
      ### Open info window ###
      #
      #
      info = @getContent null, null, obj
      info.open map?.getNewobj?() or map, marker?.getNewobj?() or marker
      info

    close: ->
      @newobj.close()


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
        position: google.maps.ControlPosition.BOTTOM_LEFT

    constructor: (@elName='#googlemaps', options=null, @map=google.maps.Map) ->
      ### XXX:  ###
      #
      #
      @el = $ @elName

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

    getAutoInfowindow: ->
      ### XXX: ###
      #
      if @el.attr('auto-infowindow') is 'false' then no else yes

    getAutoMarker: ->
      ### XXX: ###
      #
      if @el.attr('auto-marker') is 'false' then no else yes

    getAddress: ->
      ### XXX: ###
      #
      #
      @el.attr 'address'

    getTitle: ->
      ### XXX:  ###
      #
      @el.attr 'title'

    getBody: ->
      ### XXX:  ###
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
      ### XXX: ###
      #
      #
      @el = $ @elName

    setTotalDistance: (results, object=null) ->
      ### Set total distance ###
      #
      # TODO: Bugfix
      #
      data = ''
      r = results?.getNewobj?().routes or results.routes

      for routes in r
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
      ### XXX:
      @param {String} elName - Top element name.
      @param {Object} options - options.

      .. Options, e.g. ::

          options =
            total: '#total'
      ###
      #
      #
      @el = $ @elName

    setTotalDistance: (results, object=null) ->
      ### Set total distance ###
      #
      #
      total = 0
      first = results?.getNewobj?().routes[0] or results.routes[0]

      for legs in first.legs
        total += legs.distance.value
      @el.find(@options.total).text(total / 1000 + " km")


  class MAPSMODULE.NearApi extends MAPSMODULE.BaseApi
    ### For near search ###
    #
    #
    #

    near: (url, data, callback) ->
      ### ###
      #
      #
      data = @toQueryString(data) unless $.type(data) is 'string'
      @get "#{url}?#{data}", callback

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
        enabled: '#focus_enabled'
        input: yes
        value: yes
        next: yes
      near:
        form: '#near_form'
        point: '#near_point'
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
        active: '.tab-pane.active'
        direct: '#tab_direct'
        route: '#tab_route'
        show: '#tab_show'
        hide: '#tab_hide'
        near: '#tab_near'
        info: '#tab_info'
      travelmode:
        group: '#travelmode-group'
        # drive:
        # bicycle: ''
        # transit: ''
        # walk: ''
      erralert: '.erralert'
      # event:
        # near: '#click_near'
        # route: '#click_route'
        # clearaddr: '.click_clearaddr'
      event:
        current:
          id: '.click_current'
          event:
            click: (event, cls) ->
        near:
          id: '#click_near'
          event:
            click: (event, cls) ->
        route:
          id: '#click_route'
          event:
            click: (event, cls) ->
        clearaddr:
          id: '.click_clearaddr'
          event:
            click: (event, cls) ->

    constructor: (@elName='#control_panel', options=null) ->
      ### XXX:
      @param {String} elName - Top element name.
      @param {Object} options - Contoller options.

      .. Options, e.g. ::

          options:
            focus:
              input: yes
              value: yes
              next: yes
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
              active: '.tab-pane.active'
              direct: '#tab_direct'
              route: '#tab_route'
              info: '#tab_info'
              show: '#tab_show'
              hide: '#tab_hide'
            travelmode:
              group: '#travelmode-group'
              # drive:
              # bicycle: ''
              # transit: ''
              # walk: ''
            erralert: '.erralert'
            # event:
              # near: '#click_near'
              # route: '#click_route'
              # clearaddr: '.click_clearaddr'
            event:
              current:
                id: '.click_current'
                event:
                  click: (event, cls) ->
              near:
                id: '#click_near'
                event:
                  click: (event, cls) ->
              route:
                id: '#click_route'
                event:
                  click: (event, cls) ->
              clearaddr:
                id: '.click_clearaddr'
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
      if @options.focus.value is yes then @pushValue()

      # Focus input
      if @options.focus.input is yes then @focusInput()

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
      # XXX:
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
      # TODO:
      #

    getActiveTab: ->
      ### Active tab ###
      #
      @getElement 'tab.active'

    getActiveElement: (cls) ->
      ### XXX: ###
      #
      @getActiveTab().find cls

    setValue: (key, value) ->
      ### Set value to a panel ###
      #
      super value, @getElement(key)

    getValue: (key) ->
      ### Get value of a panel ###
      #
      super @getElement(key)

    setValueTostart: (value) ->
      @setValue 'start.point', value

    setValueToend: (value) ->
      @setValue 'end.point', value

    setValueToway: (value) ->
      @setValue 'way.point', "#{@getValue 'way.point'}#{value}\n"

    setPoint: (latlng, object=null) ->
      ### Set latLng to dom and next focus. ###
      #
      return false unless @isChecked 'focus.enabled'

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
      ### Check to push value element ###
      #
      elm = @getElement key

      if elm.attr 'checked'
        yes
      else if @_pushValueEl is null
        no
      else if @_pushValueEl.is elm
        yes
      else
        no

    scrollBottom: (key) ->
      ### Scroller ###
      #
      w = @getElement(key)
      w.scrollTop w.prop('scrollHeight')

    showDirectTab: ->
      @showTab @options.tab.direct

    showControlTab: ->
      @showTab @options.tab.route

    showTab: (anchor) ->
      ### For anchor tag ###
      #
      $tab = $("[data-toggle='tab'][href='#{anchor}']")
      $.Event("click").preventDefault()
      $tab.click()

    ### Current fucus element ###
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
        ).attr('checked', yes)
        @getElement(
          if key is "start.point"
            "end.point"
          else if key is "end.point"
            "way.point"
        ).focus ->
          self._pushValueEl = $ @

    pushValue: ->
      ### To input element ###
      #
      #
      self = @
      @getElement('start.point').focus(-> self._pushValueEl = $ @).blur -> self._pushValueEl = null
      @getElement('end.point').focus(-> self._pushValueEl = $ @).blur -> self._pushValueEl = null
      @getElement('way.point').focus(-> self._pushValueEl = $ @).blur -> self._pushValueEl = null

    focusInput: ->
      ### Change current focus ###
      #
      self = @
      @getElement('start.point').focus -> self.getElement('start.checked').attr 'checked', yes
      @getElement('end.point').focus -> self.getElement('end.checked').attr 'checked', yes
      @getElement('way.point').focus -> self.getElement('way.checked').attr 'checked', yes

    addEvent: (key, callback, event=@options.event) ->
      ### Common function ###
      #
      #
      if not event
        @on
          id: event[key]
          event: 'click'
          method: @["on#{key.capitalize()}"]
          callback:
            main: callback
            user: null
      else
        obj = event[key]
        @on
          id: obj.id
          event: @_getObjkey obj.event
          method: @["on#{key.capitalize()}"]
          callback:
            main: callback
            user: @_getObjvalue obj.event

    addCurrentEvent: (callback) ->
      ### Add events listener ###
      #
      # Current location event
      #
      @addEvent 'current', callback

    addNearEvent: (callback) ->
      ### Add events listener ###
      #
      # Near event
      #
      @addEvent 'near', callback

    addRouteEvent: (callback) ->
      ### Add events listener ###
      #
      # Route event
      #
      @addEvent 'route', callback

    addClearaddrEvent: (callback) ->
      ### Add events listener ###
      #
      # ClearAddress event
      #
      @addEvent 'clearaddr', callback

    getTravelmode: ->
      ### Get travelmode ###
      #
      #
      @getElement('travelmode.group').find('.active').val()

    showError: (message, status) =>
      ### Show message ###
      #
      # .. note:: Common selector ( class="erralert" )
      #
      alt = @getActiveElement @options.erralert
      alt.find('strong').text status
      alt.find('span').html message
      alt.show()
      alt.find('.close').off("click").on "click", (e) ->
        $(@).parent().hide()

    hideError: =>
      ### Hide message ###
      #
      # .. note:: Common selector ( class="erralert" )
      #
      alt = @getActiveElement @options.erralert
      alt.find('strong').text ''
      alt.find('span').text ''
      alt.hide()

    getCurrentElement: ->
      ### Get element of current location button ###
      #
      #
      @getActiveElement @options.event.current.id

    onCurrent: (event) =>
      ### Enabled navigator.geolocation ###
      #
      #
      btn = @getCurrentElement()
      boolean = if btn.hasClass("active") then no else yes

      if boolean is yes
        @nextFocus 'start.point'

      # For disabled
      btn.parents(".controls").find('[type="text"]').attr 'disabled', boolean

      # Add params
      @_addParamsToEvent event, current: {disabled: boolean}

      # Calls
      event.data?.usercallback event, @
      event.data?.maincallback event, @

    onClearaddr: (event) =>
      ### Clear form  ###
      #
      # .. note:: Common selector ( class="clearaddr" )
      #
      @getActiveElement(@options.near.point).val ''
      @getActiveElement(@options.start.point).val ''
      @getActiveElement(@options.end.point).val ''
      @getActiveElement(@options.way.point).val ''
      @getActiveElement(@options.start.checked).attr 'checked', yes
      @getActiveElement(@options.way.nonhighway).attr 'checked', no
      @getActiveElement(@options.way.nontollway).attr 'checked', no
      @getActiveElement(@options.start.point).attr 'disabled', no
      @getActiveElement(@options.near.point).attr 'disabled', no
      @getCurrentElement().removeClass "active"

      # Calls
      event.data?.usercallback event, @
      event.data?.maincallback event, @

    onRoute: (event) =>
      ### Route search request ###
      #
      #
      # Start
      if @getCurrentElement().hasClass("active")
        start = @getCurrentElement().val()
      else
        start = @getValue 'start.point'
      # End
      end = @getValue 'end.point'
      # Non highway
      hw = if @getElement("way.nonhighway").attr 'checked' then yes else no
      # Non tollway
      toll = if @getElement("way.nontollway").attr 'checked' then yes else no
      # Mode
      mode = @getTravelmode()
      # Way point
      waypts = []
      for wats in @getValue("way.point").split "\n"
        waypts.push {location: wats, stopover: yes} if wats != ''

      # Add parameter
      @_addParamsToEvent event, options: {start, end, hw, toll, mode, waypts}

      # Calls
      event.data?.usercallback event, @
      event.data?.maincallback event, @

    onNear: (event) =>
      ### Near search request ###
      #
      #
      # Start
      form = @getElement('near.form')
      if @getCurrentElement().hasClass("active")
        latlng = @getCurrentElement().val().replace(')', '').replace('(', '').split(',')
        lat = latlng[0]
        lng = latlng[1]
        $('<input>')
          .attr('type','hidden').attr('value', lat).attr('name', 'latitude')
          .appendTo form
        $('<input>')
          .attr('type','hidden').attr('value', lng).attr('name', 'longitude')
          .appendTo form

      # Add parameter
      @_addParamsToEvent event, {form}

      # Calls
      event.data?.usercallback event, @
      event.data?.maincallback event, @

    _addParamsToEvent: (event, params) ->
      ### ###
      #
      #
      event.data.controlPanel or= {}

      for key, value of params
        event.data.controlPanel[key] = value


  class MAPSMODULE.MarkerWindow extends MAPSMODULE.BaseClass
    ### Marker and InfoWindow Utilty ###
    #
    #

    ### ###
    #
    #
    options:
      lat: 0.00012
      lng: 0.0002

    ### ###
    #
    #
    @infowindows: []

    ### ###
    #
    #
    @markers: []

    ### ###
    #
    #
    calculatedArrayobj: []

    constructor: (@arrayobj, options=null, @marker=MAPSMODULE.Marker, @infowindow=MAPSMODULE.InfoWindow, @latlng=MAPSMODULE.LatLng, @event=MAPSMODULE.Event) ->
      ### XXX: ###
      #
      #

      if options isnt null then @setOptions options

      # Calc
      @setArrayObj @arrayobj

    setTitleAttributes: (@titleKeys...) ->
      ### Setter ###
      #
      #

    getTitle: (obj) ->
      ### Getter ###
      #
      #
      ("<span class='marker-info-header-#{k}'>#{obj[k]}</span>" for k in @titleKeys).join('') if @titleKeys


    getBody: (obj) ->
      ### Setter ###
      #
      #
      ("<div class='marker-info-body-#{k}'>#{obj[k]}</div>\n" for k in @bodyKeys).join('') if @bodyKeys

    setBodyAttributes: (@bodyKeys...) ->
      ### ###
      #
      #

    getMap: ->
      ### Getter ###
      #
      #
      @map

    setMap: (@map) ->
      ### ###
      #
      #
      #

    getCalculatedArrayobj: ->
      ### Getter ###
      #
      #
      @calculatedArrayobj

    setCalculatedArrayobj: (obj) ->
      ### Setter ###
      #
      #
      @calculatedArrayobj.push obj

    setInfoWindow: (infowindow) ->
      ###

      @param {MAPSMODULE.InfoWindow} infowindow
      ###
      MAPSMODULE.MarkerWindow.infowindows.push infowindow

    setMarker: (marker) ->
      ###

      @param {MAPSMODULE.Marker} marker
      ###
      MAPSMODULE.MarkerWindow.markers.push marker

    getMarker: (latlng, obj, map=@getMap()) ->
      ###

      @return {MAPSMODULE.Marker}
      ###
      marker = new @marker {position: latlng, title: @getTitle(obj), map}
      @setMarker marker
      marker

    setTemplate: (template) ->
      ###

      @param {String} Element selector
      ###
      @defaultTemplateEl = $ template
      t = @defaultTemplateEl.clone()
      @template = "<div class='marker-window-template'>#{t.attr('id', '').removeClass('hide').html()}</div>"

    getInfowindow: (marker, obj, map=@getMap()) ->
      ###
      @param {MAPSMODULE.Marker} marker
      @param {Object} obj - Mapping fields object.
      @param {MAPSMODULE.Map}
      ###
      # Get marker object
      infowindow = new @infowindow {marker, title: @getTitle(obj), map}
      infowindow.setTemplate @template if @template
      @setInfoWindow infowindow
      infowindow

    getLatLng: (lat, lng) ->
      ### Create LatLng ###
      #
      @latlng.new lat, lng

    openInfowindow: (marker, obj) ->
      ### XXX: ###
      #
      infowindow = @getInfowindow marker, obj
      if @template then infowindow.openTemplate obj else infowindow.open @getTitle(obj), @getBody(obj)
      infowindow

    closeWindows: ->
      ### All close ###
      #
      if MAPSMODULE.MarkerWindow.infowindows.length
        (infowindow.close() for infowindow in MAPSMODULE.MarkerWindow.infowindows)

    closeMarkers: ->
      ### All close ###
      #
      if MAPSMODULE.MarkerWindow.markers.length
        (marker.setMap null for marker in MAPSMODULE.MarkerWindow.markers)

    setArrayObj: (@arrayobj) ->
      ### Calculate ###
      #
      @calculatedArrayobj = []
      @calcMarkerPosition @arrayobj if @arrayobj

    calcMarkerPosition: (arrayobj) ->
      ### clcer ###
      #
      (@setCalculatedArrayobj @compute(obj) for obj in arrayobj)
        # @setMarkers
        # @setInfoWindow
        # @setCalculatedArrayobj

    compute: (obj) =>
      ### Calculate lat lng ###
      #
      return obj unless @isLatLng obj

      random = ->
        Math.floor Math.random() * 4

      ### Tail recursion ###
      #

      num = random()

      lat = @options.lat
      lng = @options.lng

      if num is 0
        obj.latitude += lat
        obj.longitude += lng
      else if num is 1
        obj.latitude -= lat
        obj.longitude -= lng
      else if num is 2
        obj.latitude -= lat
        obj.longitude += lng
      else if num is 3
        obj.latitude += lat
        obj.longitude -= lng

      @compute obj

    isLatLng: (o) ->
      for c in @calculatedArrayobj
        return true if (c.latitude is o.latitude) and (c.longitude is o.longitude)
      false

    onMemory: (marker, obj) ->
      ### On memory event listener ###
      #
      #
      self = @
      ((marker, obj) ->
        self.event.on marker, 'click', (event) ->
          ### Mouse event receiver ###
          #
          #

          # Window
          self.closeWindows()
          self.openInfowindow marker, obj

          # Any event fire
          $.event.trigger 'ajaxStop'

      )(marker, obj)

    run: (arrayobj=@getCalculatedArrayobj()) ->
      ### XXX; ###
      #

      # Closes
      @closeWindows()
      @closeMarkers()

      # Flag marker
      for obj in arrayobj
        # New marker
        marker = @getMarker @getLatLng(obj.latitude, obj.longitude), obj
        # Set info window
        # infowindow = @openInfowindow marker, obj
        # Click event
        @onMemory marker, obj


  class MAPSMODULE.RenderMap extends MAPSMODULE.BaseClass
    ### Route map class ###
    #

    ### Control panel ###
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

    ### Marker window ###
    #
    #
    markerWindow: MAPSMODULE.MarkerWindow

    ### LatLng object ###
    #
    # @param {google.maps.LatLng}
    #
    latlng: MAPSMODULE.LatLng

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

    ### NearApi object ###
    #
    # @param {MAPSMODULE.NearApi}
    #
    nearApi: MAPSMODULE.NearApi

    constructor: (options=null) ->
      ### XXX:
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
      # directPanel
      @setOptionClass options, 'directPanel'

      # Set control panel to this property.
      @setOptionClass options, 'controlPanel'

      # infoPanel
      @setOptionClass options, 'infoPanel'

      # directions renderer
      @setOptionClass options, 'directRender'

      # {google.maps.Map}
      @setOptionClass options, 'map'

      # {google.maps.Geocorder}
      @setOptionClass options, 'geocorder'

      # Geolocation
      @setOptionClass options, 'geolocation'

      # MarkerWindow
      @markerWindow = new @markerWindow()

      # Apis
      @nearApi = new @nearApi()

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
          console.log "[RenderMap.constructor] Arguments warning: options.#{key}.name is require. (#{key}.name is #{name})"
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
      # @param {String} place
      # @param {Function} callback
      #
      @geocorder.addressToLatlng place or @map.getAddress(), (results, status, message) ->
        ###
        @param {Array<Object>} results
        @param {String} status
        @param {String} message
        ###
        callback results, status, message

    getMarker: (latlng, title=@map.getTitle(), map=@map) ->
      new @marker {position: latlng, title, map}

    getInfowindow: (marker, title=@map.getTitle(), map=@map) ->
      new @infowindow {marker, map, title}

    openInfowindow: (marker, title=@map.getTitle(), body=@map.getBody()) ->
      ### XXX: ###
      #
      infowindow = @getInfowindow marker
      infowindow.open title, body
      infowindow

    setMap: (map=@map) ->
      ### To DirectionsRenderer ###
      #
      @directRender.setMap map

    setDirectPanel: (directPanelEl=@directPanel.el) ->
      ### Set panel ###
      #
      if directPanelEl.is '*'
        @directRender.setPanel directPanelEl.get(0)
      else
        console.log "[RenderMap.setDirectPanel] Arguments error: (directPanelEl is #{directPanelEl})"

    run: (options={}) ->
      ### Render map ###
      #
      @getLatlng options?.place, (results, status, message) =>
        ### Current latlng ###

        # Set curernt latlng to a map options.
        @map.setCenter @geocorder.getCurrentLocation()

        # Set map to panel
        @setMap()

        @setDirectPanel()

        # Create marker
        marker = @getMarker @geocorder.getCurrentLocation()

        # Create infowindow
        infowindow = if @map.getAutoInfowindow() then @openInfowindow marker else @getInfowindow marker

        ### Event receivers ###
        #

        @controlPanel.addCurrentEvent (event, cls) =>
          ### On submit button to current location  ###
          #
          if event.data.controlPanel.current.disabled is yes
            @_setCurrentLocation()

        @controlPanel.addClearaddrEvent (event, cls) =>
          ### On submit clear input values. ###
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
            optimizeWaypoints: yes
            avoidHighways: options.hw
            avoidTolls: options.toll
            travelMode: options.mode

          service._route (response, status) =>
            ### Request calc route ###
            #
            if status.bool is no
              @controlPanel.showError status.message, status.status
            else
              @controlPanel.showDirectTab()
              @directRender.setDirections response
              @infoPanel.setTotalDistance response
              @controlPanel.hideError()

        @controlPanel.addNearEvent (event, cls) =>
          ### Near search ###
          #
          #
          form = event.data.controlPanel.form
          @nearApi.near form.get(0).action, form.serialize(), (arrayobj) =>
            if arrayobj.length < 1
              # Zero result
              #
              @controlPanel.showError "文言を変更して、再度検索して下さい", 'NOT_FOUND '
            else
              # Set latlng to a map options.
              #
              @controlPanel.hideError()

              first = arrayobj[0]

              # Set latlong of first object into map.
              @map.setCenter @latlng.new(first.latitude, first.longitude)

              @markerWindow.setMap @map

              # Mapping title and body keys.
              @markerWindow.setTemplate '#marker_window'
              # @markerWindow.setTitleAttributes 'title', 'area_name', 'city_name', 'jobtype_name', 'pref_name'
              # @markerWindow.setBodyAttributes 'descript', 'url', 'required', 'pr', 'transport'

              # For calculate
              @markerWindow.setArrayObj arrayobj

              # Runner
              @markerWindow.run()

        @event.on marker, 'click', (event) =>
          ### Receive for mouse event  ###
          #
          @openInfowindow marker

        @event.on @map, 'click', (event) =>
          ### Mouse event receiver ###
          #
          if @controlPanel.setPoint event.latLng, @map isnt false
            @controlPanel.showControlTab()

        @event.on @directRender, 'click', (event) =>
          ### Directions changed event receiver ###
          #
          @directPanel.setTotalDistance @directRender
          @infoPanel.setTotalDistance @directRender

        # TODO: Next impl
        # google.maps.event.addListener(directionsDisplay, 'directions_changed', function() {
          # computeTotalDistance(directionsDisplay.directions);
        # })

    _setCurrentLocation: =>
      ### Set value of current location into button attributes. ###
      #

      # Call navigator.geolocation
      @geolocation.getCurrentLocation (result, status) =>
        #
        if status is yes
          # Allow geolocation
          #
          #
          btn = @controlPanel.getCurrentElement()
          btn.val "(#{result.coords.latitude},#{result.coords.longitude})"

        else if result.code is 1
          # Deny geolocation
          #
          #
          console.log "[RenderMap.run] Current location error: code #{result.code}, #{result.message}"

          if window.confirm """
          現在位置情報が設定により取得できなくなっています
          現在位置を使用する場合は、設定より位置情報を許可して下さい

          許可設定のヘルプを確認しますか？
          """
            alert "TODO: Redirect to help view"
            # w = window.open()
            # w.location.href = '/'

        else if result.code is 1000
          ### Tail recursion ###
          #
          console.log "[RenderMap.run] Warning: tail recursion.", status, result
          @_setCurrentLocation()


  MAPSMODULE
