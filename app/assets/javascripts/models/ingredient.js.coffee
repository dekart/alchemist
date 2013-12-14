window.Ingredient = class
  @types: ['blue', 'green', 'purple', 'orange', 'red', 'yellow']

  @generateMap: ->
    for x in [0 .. settings.mapSize - 1]
      for y in [0 .. settings.mapSize - 1]
        new @(x, y, @.types[_.random(@.types.length - 1)])

  constructor: (@x, @y, @type)->
    @id = _.random(0, 1000000000)

    @selected = false

  toggleSelection: ->
    @selected = not @selected
