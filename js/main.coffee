blockContextMenu = (evt) ->
  evt.preventDefault()

myElement = document.querySelector('body');
myElement.addEventListener('contextmenu', blockContextMenu);

j = jQuery

class EventRouter
  constructor: () ->
    j("body").bind "mousemove", (e) => @on("mousemove")(e)
    j("body").bind "mouseup", (e) => @on("mouseup")(e)
    j("body").bind "mouseclick", (e) ->
      if(event.button==2)
        @on("mouseright")(e)
        return false
  on: (type) =>
    (e) =>
      action = this["on#{type}"]
      if action?
        action(e)

  bind: (type, f, obj) ->
    this["on#{type}"] = (e) -> f.call(obj, e)

  unbind: (type) ->
    this["on#{type}"] = null

window.eventRouter = new EventRouter()

window.idIterator = 0
window.makeId = () ->
  return window.idIterator++

class Album
  constructor: (mockNo)->
    @state = "closed"
    @id = "album-" + makeId()
    j("body").append """
      <div class="positioner" id="#{@id}" rotation="0">
        <div class="ctx">
          <div class="cd" >
            <div class="case">
              <div class="ctx">
                <div class="back">
                  <div class="ctx">
                    <div class="top"></div>
                    <div class="right"></div>
                    <div class="bottom"></div>
                  </div>
                </div>
                <div class="bar">
                  <div class="ctx">
                  <div class="ridge"></div>
                  <div class="ridge"></div>
                  <div class="ridge"></div>
                  <div class="ridge"></div>
                  <div class="ridge"></div>
                  <div class="ridge"></div>
                  <div class="ridge"></div>
                  <div class="ridge"></div>
                  </div>
                </div>
                <div class="tray">
                  <div class='ctx'>
                    <div class="template">

                    </div>
                  </div>
                </div>
                <div class="lid">
                  <div class="cover mock no#{mockNo}"></div>
                  <div class="pressed">
                    <div class='ctx'>
                    <div class="top"></div>
                    <div class="right"></div>
                    <div class="left"></div>
                    <div class="bottom"></div>
                    <div class="overlay"></div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
            </div>
          </div>
        </div>
      </div>
    """
    @elem().mousedown (e) => @mousedown(e)

  mousedown: (e) ->
    console.log event.button
    if event.button is 2
      eventRouter.bind "mousemove", @rotateAlbum(), this
      eventRouter.bind "mouseup", (e) ->
        console.log "mouseup"
        eventRouter.unbind "mousemove"
    else if event.button is 0
      eventRouter.bind "mousemove", @moveAlbum(e), this
      eventRouter.bind "mouseup", (e) ->
        console.log "mouseup"
        eventRouter.unbind "mousemove"
    else
      if @state is "closed"
        @elem().find(".lid").css { transform: "rotateY(180deg)"}
        @state = "opening"
        state = =>
          @state = "open"
        setTimeout(state, 1000)
      if @state is "open"
        @elem().find(".lid").css { transform: "rotateY(0deg)"}
        @state = "closing"
        state = =>
          @state = "closed"
        setTimeout(state, 1000)

  moveAlbum: (ev) ->
    posX = @elem().offset().left
    posY = @elem().offset().top
    startX = ev.pageX
    startY = ev.pageY
    (e) ->
      @elem().css
        top: (posY + (e.pageY - startY)) + "px"
        left: (posX+ (e.pageX - startX)) + "px"

  rotateAlbum: () ->
    centerX = @elem().offset().left + (@elem().width() / 2)
    centerY = @elem().offset().top + (@elem().height() / 2)
    if @elem().attr("rotation")?
      startAng = parseFloat @elem().attr("rotation")
    else
      startAng = 90
    (ev) ->
      deltaX = ev.pageX - centerX
      deltaY = ev.pageY - centerY
      if Math.abs(deltaX) + Math.abs(deltaY) < 40
        ang = startAng
      else
        ang = (Math.atan2(deltaY, deltaX) * 180 / Math.PI) + 90
      console.log ev.pageY, ev.pageX, ang
      @elem().css
        "transform": "rotate(#{ang}deg)"
      @elem().attr "rotation", ang

  elem: ->
    j("##{@id}")


new Album(1)
new Album(2)
