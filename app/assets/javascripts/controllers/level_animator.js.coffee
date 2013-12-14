#= require ./animator

window.LevelAnimator = class extends Animator
  ingredientSize: 55
  swapAnimationSpeed: 500

  loops: # [StartFrame, EndFrame, Speed]
   ingredient_blue:   {frames: [0,  1], speed: 0.3}
   ingredient_green:  {frames: [0,  1], speed: 0.3}
   ingredient_purple: {frames: [0,  1], speed: 0.3}
   ingredient_orange: {frames: [0,  1], speed: 0.3}
   ingredient_red:    {frames: [0,  1], speed: 0.3}
   ingredient_yellow: {frames: [0,  1], speed: 0.3}

  constructor: (controller)->
    super(controller)

    @background_layer = new PIXI.DisplayObjectContainer()
    @ingredient_layer = new PIXI.DisplayObjectContainer()
    @interface_layer  = new PIXI.DisplayObjectContainer()

    @stage.addChild(@background_layer)
    @stage.addChild(@ingredient_layer)
    @stage.addChild(@interface_layer)


  prepareTextures: ->
    return unless @.loops?

    for id, animation of @.loops
      animation.textures = []

      for frame in [animation.frames[0] .. animation.frames[1]]
        animation.textures.push(
          PIXI.Texture.fromFrame("#{ id }_#{ @.zeroPad(frame, 4) }.png")
        )

  activate: ->
    return unless super

    @.addSprites()

    @.attachRendererTo(@controller.el)

  addSprites: ->
    @background_sprite = PIXI.Sprite.fromImage(preloader.paths.background)

    @background_layer.addChild(@background_sprite)

    for column in @controller.ingredients.ingredients
      for ingredient in column
        @ingredient_layer.addChild(@.createIngredientSprite(ingredient))

    @highlight = PIXI.Sprite.fromFrame("highlight.png")

    @interface_layer.addChild(@highlight)

    @sprites_added = true

  animate: =>
    unless @paused_at
      @controller.updateState()

      @.updateSpriteStates()

    super

  updateSpriteStates: ->
    return unless @sprites_added

    for sprite in @ingredient_layer.children
      @.updateIngredientSprite(sprite)

    if @.isMouseWithinIngredients(@controller.mouse_position)
      position = @.mousePositionToIngredientPosition(@controller.mouse_position)

      @highlight.position = new PIXI.Point(position.x * @.ingredientSize, position.y * @.ingredientSize)


  createIngredientSprite: (ingredient)->
    sprite = new PIXI.MovieClip(@.loops["ingredient_#{ ingredient.type }"].textures)
    sprite.position = new PIXI.Point(ingredient.x * @.ingredientSize, ingredient.y * @.ingredientSize)
    sprite.source = ingredient
    sprite

  isMouseWithinIngredients: (position)->
    0 <= position.x < settings.mapSize * @.ingredientSize and
    0 <= position.y < settings.mapSize * @.ingredientSize

  mousePositionToIngredientPosition: (position)->
    x = Math.floor(position.x / @.ingredientSize)
    y = Math.floor(position.y / @.ingredientSize)

    {
      x: if 0 <= x < settings.mapSize then x else if x < 0 then 0 else settings.mapSize - 1
      y: if 0 <= y < settings.mapSize then y else if y < 0 then 0 else settings.mapSize - 1
    }

  animateIngredientSwap: (ingredient1, ingredient2)->
    @swap_animation_started = Date.now()

    sprite1 = _.find(@ingredient_layer.children, (child)=> child.source.id == ingredient1.id )
    sprite2 = _.find(@ingredient_layer.children, (child)=> child.source.id == ingredient2.id )

    sprite1.swappingWith = ingredient2
    sprite2.swappingWith = ingredient1

  updateIngredientSprite: (sprite)->
    if sprite.swappingWith?
      if Date.now() - @swap_animation_started > @.swapAnimationSpeed
        sprite.textures = @.loops["ingredient_#{ sprite.source.type }"].textures

        sprite.position.x = sprite.source.x * @.ingredientSize
        sprite.position.y = sprite.source.y * @.ingredientSize

        delete sprite.swappingWith
      else
        progress = (Date.now() - @swap_animation_started) / @.swapAnimationSpeed

        sprite.position.x = (sprite.swappingWith.x + (1 - progress) * (sprite.source.x - sprite.swappingWith.x)) * @.ingredientSize
        sprite.position.y = (sprite.swappingWith.y + (1 - progress) * (sprite.source.y - sprite.swappingWith.y)) * @.ingredientSize

    sprite.gotoAndStop(
      if sprite.source.selected then 1 else 0
    )
