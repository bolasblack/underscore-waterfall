_.mixin
  waterfall: (fn) ->
    stacks = {}
    calls = {}
    metaMethods = ["then", "done", "fail", "anyway"]

    start = ->
      fn null, arguments..., callback

    callback = (err, args...) ->
      if err
        calls.fail err
        calls.anyway err
        return

      if stacks.then.length
        thenFn = stacks.then.shift()
        thenFn? err, args..., callback
        return

      calls.done err, args...
      calls.anyway err, args...

    _(metaMethods).forEach (method) ->
      stacks[method] ?= []

      start[method] = (callback) ->
        stacks[method].push callback
        this

      calls[method] = ->
        stack = stacks[method]
        return unless stack?
        while stack.length
          fn = stack.shift()
          fn? null, arguments...

    start
