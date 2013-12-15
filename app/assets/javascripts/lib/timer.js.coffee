window.Timer = class
  constructor: (@countdown)->
    @finish_at = Date.now() + @countdown * 1000

  currentValue: ->
    value = Math.ceil((@finish_at - Date.now()) / 1000)

    if value < 0 then 0 else value

  increment: (value)->
    if value + @.currentValue() > settings.timeLimit
      @finish_at = Date.now() + settings.timeLimit * 1000
    else
      @finish_at += value * 1000