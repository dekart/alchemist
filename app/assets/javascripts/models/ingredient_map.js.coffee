window.IngredientMap = class
  @generate: ->
    new @(
      for x in [0 .. settings.mapSize - 1]
        for y in [0 .. settings.mapSize - 1]
          new Ingredient(x,y, Ingredient.types[_.random(Ingredient.types.length - 1)])
    )

  constructor: (@ingredients)->
    #ok

  get: (x, y)->
    @ingredients[x][y]

  isMatch: (ingredient1, ingredient2)->
    @.isCoordinateMatch(ingredient1, ingredient2) and
    @.isTypeMatch(ingredient1, ingredient2) and
    @.isPurposeMatch(ingredient1, ingredient2)

  isCoordinateMatch: (ingredient1, ingredient2)->
    (ingredient1.x - 1 <= ingredient2.x <= ingredient1.x + 1 and ingredient1.y == ingredient2.y) or
    (ingredient1.y - 1 <= ingredient2.y <= ingredient1.y + 1 and ingredient1.x == ingredient2.x)

  isTypeMatch: (ingredient1, ingredient2)->
    ingredient1.type != ingredient2.type

  isPurposeMatch: (ingredient1, ingredient2)->
    [ingredient1.type, ingredient2.type] = [ingredient2.type, ingredient1.type] # Temporary change types to emulate position change

    matches1 = @.matchesOf(ingredient1)
    matches2 = @.matchesOf(ingredient2)

    [ingredient1.type, ingredient2.type] = [ingredient2.type, ingredient1.type] # Return types back

    for match in matches1
      return true if match
    for match in matches2
      return true if match

    return false

  matchesOf: (ingredient)->
    [
      @ingredients[ingredient.x - 2]?[ingredient.y]?.type == @ingredients[ingredient.x - 1]?[ingredient.y]?.type == ingredient.type
      @ingredients[ingredient.x - 1]?[ingredient.y]?.type == @ingredients[ingredient.x + 1]?[ingredient.y]?.type == ingredient.type
      @ingredients[ingredient.x + 1]?[ingredient.y]?.type == @ingredients[ingredient.x + 2]?[ingredient.y]?.type == ingredient.type

      @ingredients[ingredient.x]?[ingredient.y - 2]?.type == @ingredients[ingredient.x]?[ingredient.y - 1]?.type == ingredient.type
      @ingredients[ingredient.x]?[ingredient.y - 1]?.type == @ingredients[ingredient.x]?[ingredient.y + 1]?.type == ingredient.type
      @ingredients[ingredient.x]?[ingredient.y + 1]?.type == @ingredients[ingredient.x]?[ingredient.y + 2]?.type == ingredient.type
    ]