angular.module 'hello'
.factory 'handy', () ->

  @openInMap = (lat,lon) ->
    if navigator.platform.match(/(Mac|iPhone|iPod|iPad)/i) 
      is_apple = true
    else
      is_apple = false

    if is_apple
      maplink = "http://maps.apple.com/?q="
    else
      maplink = "http://maps.google.com/?saddr="

    link = maplink + "#{lat},#{lon}"

    location.href = link

  @isMobile = () ->
    if /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEshrinked|Opera Mini/i.test navigator.userAgent
      m = true
    else
      m = false
    return m


  @inViewport = (viewport_element,element,treshold) ->
    viewport =
      top: viewport_element.scrollTop()

    viewport.bottom = viewport.top + viewport_element.height()

    bounds = element.offset()
    bounds.bottom = bounds.top + element.outerHeight() + viewport.top

    not (viewport.bottom < (bounds.top + viewport.top) or viewport.top > bounds.bottom)

  @scrollbarWidth = () =>
    outer = document.createElement("div")
    outer.style.visibility = "hidden"
    outer.style.width = "100px"
    document.body.appendChild(outer)
    widthNoScroll = outer.offsetWidth
    outer.style.overflow = "scroll"
    inner = document.createElement("div")
    inner.style.width = "100%"
    outer.appendChild(inner)        
    widthWithScroll = inner.offsetWidth
    outer.parentNode.removeChild(outer)
    sb = widthNoScroll - widthWithScroll
    if sb <= 16
      sb = 16
    if @isMobile()
      sb = 0
    sb

  @isFocused = ->
    $("input,div,p,textarea,.focusable").is(":focus")

  @keyboard = (e,keys,checkFocus=true) ->
    code = if e.keyCode then e.keyCode else e.which

    meta = e.metaKey || e.ctrlKey
    alt = e.altKey
    shift = e.shiftKey

    if checkFocus
      focused = @isFocused()
    else
      focused = false

    # key combinations
    codes = 
      "return":13
      "up":38
      "down":40
      "left":37
      "right":39
      "space":32
      "backspace":8
      "tab":9
      "del":46
      "h":72
      "p":80
      "escape":27
      "meta+i":73
      "meta+s":83
      "meta+u":85
      "meta+h":72
      "meta+l":76
      "meta+b":66
      "?":191
      "0":96
      "1":97
      "2":98
      "3":99
      "4":100
      "5":101
      "6":102
      "7":103
      "8":104
      "9":105

    commands = keys.toLowerCase().split(" ")

    for command in commands
      if not focused
        combo = command.split("+")

        if combo.length > 1
          # check with one primary key
          if combo.length is 2 and eval(combo[0])
              primary = true
          # check with two primary keys
          if combo.length is 3 and eval(combo[0]) and eval(combo[1])
              primary = true
          # check key
          if primary and code is codes[command]
            return true
        else
          # check key
          if code is codes[command]
            return true   

    return false

  return @

.directive 'hideScrollBar', (handy) ->
  restrict: 'C'
  link: (scope, element, attrs) ->
    hideBar = () ->
      sb = handy.scrollbarWidth()
      # pw = element.parent().outerWidth()
      ww = $(window).width()

      element.css
        width:ww + sb + sb

      element.children(".wrapper").css
        width: ww + sb

      element.find(".full-width").css
        width: ww


    hideBar()
    
    $(window).on "resize", () ->
      hideBar()

