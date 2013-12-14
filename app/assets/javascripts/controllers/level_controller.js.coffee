#= require ./level_animator

window.LevelController = class extends BaseController
  className: 'level_screen'

  constructor: ->
    super

    @ingredients = IngredientMap.generate()
    @selected_ingredient = null

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
    position = @animator.mousePositionToIngredientPosition(@mouse_position)
    clicked_ingredient = @ingredients.get(position.x, position.y)
    console.log(clicked_ingredient.type)

    if @selected_ingredient
      if @ingredients.isMatch(@selected_ingredient, clicked_ingredient)
        @selected_ingredient.toggleSelection()

        @.swapIngredients(@selected_ingredient, clicked_ingredient)

        @selected_ingredient = null
      else
        console.log('no match')
    else
      @selected_ingredient = clicked_ingredient

      clicked_ingredient.toggleSelection()

    e.preventDefault()

  onMouseMove: (e)=>
    @mouse_position.x = e.offsetX
    @mouse_position.y = e.offsetY

  updateState: ->
    # Updating object states

  finish: ->
    @animator.deactivate()

    # Level finished

  swapIngredients: (ingredient1, ingredient2)->
    [ingredient1.type, ingredient2.type] = [ingredient2.type, ingredient1.type]

    @animator.animateIngredientSwap(ingredient1, ingredient2)
