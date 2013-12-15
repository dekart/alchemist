#= require ./level_animator

window.LevelController = class extends BaseController
  className: 'level_screen'

  constructor: ->
    super

    @ingredients = new IngredientMap()
    @selected_ingredient = null

    @mouse_position = {x: 0, y: 0}

    @animator = new LevelAnimator(@)

    @timer = new Timer(settings.timeLimit)

    @potion = new Potion(4)

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

  updateState: ->
    if @timer.currentValue() == 0
      @.finish()

  onClick: (e)=>
    e.preventDefault()

    return if @animator.isBlockingAnimationInProgress()

    position = @animator.mousePositionToIngredientPosition(@mouse_position)
    clicked_ingredient = @ingredients.get(position.x, position.y)

    if @selected_ingredient
      @selected_ingredient.toggleSelection()

      if @ingredients.isMatch(@selected_ingredient, clicked_ingredient)
        @.swapIngredients(@selected_ingredient, clicked_ingredient)

        @selected_ingredient = null
      else
        clicked_ingredient.toggleSelection()

        @selected_ingredient = clicked_ingredient
    else
      @selected_ingredient = clicked_ingredient

      clicked_ingredient.toggleSelection()


  onMouseMove: (e)=>
    @mouse_position.x = e.offsetX
    @mouse_position.y = e.offsetY

  finish: ->
    @animator.deactivate()

    FinishDialogController.show()

  swapIngredients: (ingredient1, ingredient2)->
    [ingredient1.type, ingredient2.type] = [ingredient2.type, ingredient1.type]

    @animator.animateIngredientSwap(ingredient1, ingredient2)

  checkMatches: ->
    @exploding = @ingredients.getExplodingIngredients()

    return if @exploding.length == 0

    for ingredient in @exploding
      ingredient.exploding = true

    @animator.animateExplosion(@exploding)

  checkAffected: ->
    for ingredient in @exploding
      ingredient.exploding = false

    collected = @potion.checkCollectedIngredients(@exploding)

    @animator.animateCollected(collected)

    affected = @ingredients.checkAffectedIngredients(@exploding)

    @animator.animateAffected(affected)

    @exploding = null

  updatePotion: ->
    return unless @potion.isComplete()

    @potion = new Potion(4)

    @timer.increment(settings.timeBonus)

  onSwapAnimationFinished: ->
    @.checkMatches()

  onExplosionAnimationFinished: ->
    @.checkAffected()

  onAffectedAnimationFinished: ->
    @.checkMatches()

  onCollectedAnimationFinished: ->
    @.updatePotion()