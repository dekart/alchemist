#= require ./animator

window.LevelAnimator = class extends Animator
  ingredientSize: 55
  ingredientGridOffset: 50

  swapAnimationSpeed: 250
  explosionAnimationSpeed: 200
  affectedAnimationSpeed: 300

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

    @ingredients = []


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

    for column, x in @controller.ingredients.ingredients
      for ingredient, y in column
        sprite = @.createIngredientSprite(ingredient)

        @ingredient_layer.addChild(sprite)

        @ingredients[x] ?= []
        @ingredients[x][y] = sprite

    @highlight = PIXI.Sprite.fromFrame("highlight.png")
    @highlight.anchor.x = 0.5
    @highlight.anchor.y = 0.5

    @interface_layer.addChild(@highlight)

    @sprites_added = true

  animate: =>
    unless @paused_at
      if @swap_animation_started and @.isSwapAnimationFinished()
        @swap_animation_started = null

        @controller.onSwapAnimationFinished()

      if @explosion_animation_started and @.isExplosionAnimationFinished()
        @explosion_animation_started = null

        @controller.onExplosionAnimationFinished()

      if @affected_animation_started and @.isAffectedAnimationFinished()
        @affected_animation_started = null

        @controller.onAffectedAnimationFinished()

      @.updateSpriteStates()

    super

  updateSpriteStates: ->
    return unless @sprites_added

    for sprite in @ingredient_layer.children
      @.updateIngredientSprite(sprite)

    if @.isMouseWithinIngredients(@controller.mouse_position)
      position = @.mousePositionToIngredientPosition(@controller.mouse_position)

      @highlight.position.x = @.gridToScene(position.x)
      @highlight.position.y = @.gridToScene(position.y)

  createIngredientSprite: (ingredient)->
    sprite = new PIXI.MovieClip(@.loops["ingredient_#{ ingredient.type }"].textures)
    sprite.position.x = @.gridToScene(ingredient.x)
    sprite.position.y = @.gridToScene(ingredient.y)
    sprite.anchor.x = 0.5
    sprite.anchor.y = 0.5
    sprite.source = ingredient
    sprite

  isMouseWithinIngredients: (position)->
    @.gridToScene(-1) < position.x < @.gridToScene(settings.mapSize) and
    @.gridToScene(-1) < position.y < @.gridToScene(settings.mapSize)

  mousePositionToIngredientPosition: (position)->
    x = Math.floor((position.x - @.ingredientGridOffset) / @.ingredientSize + 0.5)
    y = Math.floor((position.y - @.ingredientGridOffset) / @.ingredientSize + 0.5)

    {
      x: if 0 <= x < settings.mapSize then x else if x < 0 then 0 else settings.mapSize - 1
      y: if 0 <= y < settings.mapSize then y else if y < 0 then 0 else settings.mapSize - 1
    }

  animateIngredientSwap: (ingredient1, ingredient2)->
    @swap_animation_started = Date.now()

    sprite1 = @ingredients[ingredient1.x][ingredient1.y]
    sprite2 = @ingredients[ingredient2.x][ingredient2.y]

    sprite1.swappingWith = ingredient2
    sprite2.swappingWith = ingredient1

  updateIngredientSprite: (sprite)->
    if sprite.swappingWith?
      if not @swap_animation_started or @.isSwapAnimationFinished()
        sprite.textures = @.loops["ingredient_#{ sprite.source.type }"].textures

        sprite.position.x = @.gridToScene(sprite.source.x)
        sprite.position.y = @.gridToScene(sprite.source.y)

        delete sprite.swappingWith
      else
        progress = (Date.now() - @swap_animation_started) / @.swapAnimationSpeed

        sprite.position.x = @.gridToScene(sprite.swappingWith.x + (1 - progress) * (sprite.source.x - sprite.swappingWith.x))
        sprite.position.y = @.gridToScene(sprite.swappingWith.y + (1 - progress) * (sprite.source.y - sprite.swappingWith.y))

    if sprite.exploding
      if not @explosion_animation_started or @.isExplosionAnimationFinished()
        sprite.scale.x = 1
        sprite.scale.y = 1

        delete sprite.exploding
      else
        progress = (Date.now() - @explosion_animation_started) / @.explosionAnimationSpeed

        sprite.scale.x = 1 - progress
        sprite.scale.y = 1 - progress

    if sprite.affected_displacement
      if not @affected_animation_started or @.isAffectedAnimationFinished()
        sprite.position.y = @.gridToScene(sprite.source.y)

        delete sprite.affected_displacement
      else
        progress = (Date.now() - @affected_animation_started) / @.affectedAnimationSpeed

        sprite.position.y = @.gridToScene(sprite.source.y - (1 - progress) * sprite.affected_displacement)

    sprite.gotoAndStop(
      if sprite.source.selected then 1 else 0
    )

  gridToScene: (coordinate)->
    @.ingredientGridOffset + coordinate * @.ingredientSize

  isSwapAnimationFinished: ->
    Date.now() - @swap_animation_started > @.swapAnimationSpeed


  animateExplosion: (ingredients)->
    @explosion_animation_started = Date.now()

    for ingredient in ingredients
      @ingredients[ingredient.x][ingredient.y].exploding = true

  isExplosionAnimationFinished: ->
    Date.now() - @explosion_animation_started > @.explosionAnimationSpeed


  animateAffected: (affected)->
    @affected_animation_started = Date.now()

    for [ingredient, displacement] in affected
      sprite = @ingredients[ingredient.x][ingredient.y]
      sprite.affected_displacement = displacement
      sprite.textures = @.loops["ingredient_#{ sprite.source.type }"].textures

  isAffectedAnimationFinished: ->
    Date.now() - @affected_animation_started > @.affectedAnimationSpeed

  isAnimationInProgress: ->
    @swap_animation_started or @explosion_animation_started or @affected_animation_started