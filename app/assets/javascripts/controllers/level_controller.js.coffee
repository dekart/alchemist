#= require ./level_animator

window.LevelController = class extends BaseController
  className: 'level_screen'

  constructor: ->
    super

    @ingredients = Ingredient.generateMap()

    @mouse_position = {x: 0, y: 0}

    @animator = new LevelAnimator(@)

  show: ->
    @.setupEventListeners()

    @.render()

  setupEventListeners: ->
    $(document).on('keydown', @.onKeyDown)
    $(document).on('keyup', @.onKeyUp)

    @el.on('click', 'canvas', @.onClick)
    @el.on('mousemove', 'canvas', @.onMouseMove)

  render: ->
    @animator.deactivate()

    @el.appendTo('#game')

    @animator.activate()

  onClick: (e)=>
    console.log('click', e)

    e.preventDefault()

  onMouseMove: (e)=>
    @mouse_position.x = e.offsetX
    @mouse_position.y = e.offsetY

  updateState: ->
    # Updating object states

  finish: ->
    @animator.deactivate()

    # Level finished