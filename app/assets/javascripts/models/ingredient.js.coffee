window.Ingredient = class
  @types: ['blue', 'green', 'purple', 'orange', 'red', 'yellow']

  constructor: (@x, @y, @type)->
    @id = _.random(0, 1000000000)

    @selected = false

  toggleSelection: ->
    @selected = not @selected
