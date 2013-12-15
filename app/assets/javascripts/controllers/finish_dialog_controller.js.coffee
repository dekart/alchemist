window.FinishDialogController = class extends BaseController
  className: 'finish dialog'

  @show: (args...)->
    @controller ?= new @()
    @controller.show(args...)

  constructor: ->
    super

    @overlay = $("<div class='dialog_overlay'></div>")

  show: (@level)->
    @.setupEventListeners()

    @el.css(opacity: 0).appendTo('#game_screen')

    @.render()

    @overlay.appendTo('#game')

    @el.fadeTo(400, 1)

    @visible = true

  close: ->
    @.unbindEventListeners()

    @overlay.detach()
    @el.detach()

    @visible = false

    document.location = document.location

  render: ->
    @html(
      @.renderTemplate('finish_dialog')
    )

  setupEventListeners: ->
    @el.on('click', '.replay', @.onCloseClick)

    $(document).on('keydown', @.onKeyDown)

  unbindEventListeners: ->
    @el.off('click', '.close', @.onCloseClick)

    $(document).off('keydown', @.onKeyDown)

  onCloseClick: =>
    @.close()

  onKeyDown: (e)=>
    @.close() if e.keyCode == 27

