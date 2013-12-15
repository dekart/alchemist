window.Timer = class
  constructor: (@countdown)->
    @finish_at = Date.now() + @countdown * 1000

  currentValue: ->
    value = Math.ceil((@finish_at - Date.now()) / 1000)

    if value < 0 then 0 else value

  increment: (value)->
    @finish_at += value * 1000