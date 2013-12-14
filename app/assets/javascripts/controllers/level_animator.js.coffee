#= require ./animator

window.LevelAnimator = class extends Animator
  #loops: # [StartFrame, EndFrame, Speed]
  #  some: {frames: [0,  3], speed: 0.3}

  constructor: (controller)->
    super(controller)

    @background_layer = new PIXI.DisplayObjectContainer()

    @stage.addChild(@background_layer)


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

    @sprites_added = true

  animate: =>
    unless @paused_at
      @controller.updateState()

      @.updateSpriteStates()

    super

  updateSpriteStates: ->
    return unless @sprites_added


