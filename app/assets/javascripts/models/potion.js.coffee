window.Potion = class
  constructor: (@size)->
    @ingredients = []

    for c in [1 .. @size]
      @ingredients.push [Ingredient.randomType(), false]

