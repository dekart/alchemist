#= require ./animator

window.LevelAnimator = class extends Animator
  #loops: # [StartFrame, EndFrame, Speed]
  #  some: {frames: [0,  3], speed: 0.3}

  constructor: (controller)->
    super(controller)

    @background_layer = new PIXI.DisplayObjectContainer()
    @ingredient_layer = new PIXI.DisplayObjectContainer()

    @stage.addChild(@background_layer)
    @stage.addChild(@ingredient_layer)


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

    for column in @controller.ingredients
      for ingredient in column
        @ingredient_layer.addChild(@.createIngredientSprite(ingredient))

    @sprites_added = true

  animate: =>
    unless @paused_at
      @controller.updateState()

      @.updateSpriteStates()

    super

  updateSpriteStates: ->
    return unless @sprites_added

  createIngredientSprite: (ingredient)->
    sprite = PIXI.Sprite.fromFrame("ingredient_#{ ingredient.type }.png")
    sprite.position = new PIXI.Point(ingredient.x * 55, ingredient.y * 55)
    sprite.source = ingredient
    sprite
