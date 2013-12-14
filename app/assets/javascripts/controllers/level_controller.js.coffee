#= require ./level_animator

window.LevelController = class extends BaseController
  className: 'level_screen'

  constructor: ->
    super

    @mouse_position = [0, 0]

    @animator = new LevelAnimator(@)

  show: ->
    @.setupEventListeners()

    @.render()

  setupEventListeners: ->
    $(document).on('keydown', @.onKeyDown)
    $(document).on('keyup', @.onKeyUp)

    @el.on('click', 'canvas', @.onClick)

  render: ->
    @animator.deactivate()

    @el.appendTo('#game')

    @animator.activate()

  onClick: (e)=>
    console.log('click', e)

    e.preventDefault()

  updateState: ->
    # Updating object states

  finish: ->
    @animator.deactivate()

    # Level finished