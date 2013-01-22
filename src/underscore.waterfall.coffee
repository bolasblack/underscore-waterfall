funcHolder = (originArgs) ->
  (args..., callback) ->
    callback null, originArgs...

_.mixin
  waterfall: (fn) ->
    stacks = {}
    calls = {}
    metaMethods = ["then", "done", "fail", "anyway"]
    thenArgs = []

    cacheArgs = (args) ->
      args = _(args).toArray()
      if args.length is 0
        thenArgs.push undefined
      else if args.length is 1
        thenArgs.push args[0]
      else
        thenArgs.push args

    start = ->
      cacheArgs arguments
      fn arguments..., callback

    callback = (err, args...) ->
      if err
        calls.fail err
        calls.anyway err
        return

      if stacks.then.length
        cacheArgs args
        thenFn = stacks.then.shift()
        thenFn? args..., callback
        return

      calls.done thenArgs...
      calls.anyway null, thenArgs...

    _(metaMethods).forEach (method) ->
      stacks[method] ?= []

      start[method] = (callback) ->
        if _(callback).isFunction()
          stacks[method].push callback
        else if callback
          stacks[method].push funcHolder _(arguments).toArray()
        this

      calls[method] = ->
        stack = stacks[method]
        return unless stack?
        while stack.length
          fn = stack.shift()
          if method is "then"
            fn? arguments..., callback
          else
            fn? arguments...

    start
