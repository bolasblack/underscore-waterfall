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

  deferred: (fn) ->
    thens = [] # then handler stack
    fails = [] # fail handler stack
    padding = false
    failed = false

    lastErr = null
    lastArg = []
    callback = (err, args...) ->
      if err
        lastErr = err
        failed = true
        while fails.length
          failFn = fails.shift()
          failFn? err

      while thens.length
        {fn: thenFn, type} = thens.shift()
        if not failed or type is "anyway"
          thenFn? args..., callback
          break

      lastArg = args if padding is "then"
      padding = false

    promise = ->
      obj =
        fail: (fn) ->
          return _.clone(promise) unless fn
          if failed then fn(lastErr) else fails.push fn
          promise()

      _.forEach ["then", "anyway"], (type) ->
        obj[type] = (fn) ->
          return promise() unless fn?
          return promise() if failed and type is "then"
          unless _(fn).isFunction()
            fn = funcHolder _(arguments).toArray()
          if padding
            thens.push {fn, type}
          else
            padding = type
            fn lastArg..., callback
          promise()

      obj

    promise().then fn
