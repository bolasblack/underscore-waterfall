_.mixin
  then: (obj, fn) ->
    if _(fn).isFunction() then fn() else fn
    obj

autoCallbackSpy = (spy, err, args...) ->
  (callArgs..., callback) ->
    spy callArgs...
    callback err, args...

describe "the underscore waterfall plugin", ->
  describe "the _.waterfall method", -> # [[[
    beforeEach ->
      @doneSpy = sinon.spy()
      @anywaySpy1 = sinon.spy()
      _.waterfall((arg1, callback) =>
        @originalArg = arg1
        callback null, "some args"
      ).then((arg1, callback) =>
        @thenFn1Arg = arg1
        callback null, "args1", "args2"
      ).then((arg1, arg2, callback) =>
        @thenFn2Arg1 = arg1
        @thenFn2Arg2 = arg2
        callback null, "some other args"
      ).then(
        "straight", "passin", "arguments"
      ).then((arg1, arg2, arg3, callback) =>
        @thenFn4Arg1 = arg1
        @thenFn4Arg2 = arg2
        @thenFn4Arg3 = arg3
        callback()
      ).done((args...) =>
        @doneArgs = args
        @doneSpy args...
        # call when `thenFn` finish
      ).anyway(@anywaySpy1
      )("first function args")

      @failSpy = sinon.spy()
      @anywaySpy2 = sinon.spy()
      _.waterfall((callback) ->
        callback()
      ).then(
      ).then((callback) =>
        @thenFn5Called = true
        callback()
      ).then((callback) ->
        callback "some error message", "other", "args"
      ).fail(@failSpy
        # call when any `thenFn` error
      ).anyway(@anywaySpy2
        # call another done or fail
      )()

    afterEach ->
      delete @originalArg
      delete @thenFn1Arg
      delete @thenFn2Arg1
      delete @thenFn2Arg2
      delete @thenFn4Arg1
      delete @thenFn4Arg2
      delete @thenFn4Arg3
      delete @doneArgs
      delete @doneSpy
      delete @failSpy
      delete @anywaySpy1
      delete @anywaySpy2
      delete @thenFn5Called

    it "should make original function also callable", ->
      @originalArg.should.equal "first function args"

    it "should call function registered by `then` method", ->
      @thenFn1Arg.should.equal "some args"
      @thenFn2Arg1.should.equal "args1"
      @thenFn2Arg2.should.equal "args2"

    it "should pass in object to callback what not a function", ->
      @thenFn4Arg1.should.equal "straight"
      @thenFn4Arg2.should.equal "passin"
      @thenFn4Arg3.should.equal "arguments"

    it "should call function registered by `done` method", ->
      @doneSpy.calledWith(
        "first function args",
        "some args",
        ["args1", "args2"],
        "some other args",
        ["straight", "passin", "arguments"]
      ).should.be.true

    it "should skip when called by empty argument", ->
      @thenFn5Called.should.be.true

    it "should call function registered by `fail` method", ->
      @failSpy.calledWith("some error message").should.be.true

    it "should call function registered by `anyway` method when done", ->
      @anywaySpy1.calledWith(
        null,
        "first function args",
        "some args",
        ["args1", "args2"],
        "some other args",
        ["straight", "passin", "arguments"]
      ).should.be.true

    it "should call function registered by `anyway` method when failed", ->
      @anywaySpy2.calledWith("some error message").should.be.true
  # ]]]

  describe "the _.deferred method", ->
    beforeEach ->
      @originFnSpy = sinon.spy()
      @errSpy1 = sinon.spy()
      @errSpy2 = sinon.spy()
      @thenSpy1 = sinon.spy()
      @thenSpy2 = sinon.spy()
      @thenSpy3 = sinon.spy()
      @thenSpy4 = sinon.spy()
      @thenSpy5 = sinon.spy()
      @anywaySpy1 = sinon.spy()

      _(autoCallbackSpy @originFnSpy, null, "a")
        .deferred()
        .then(autoCallbackSpy @thenSpy1, null, "a", "b")
        .fail(@errSpy1)
        .then(autoCallbackSpy @thenSpy2)
        .then()
        .then(autoCallbackSpy @thenSpy3)
        .then("some", "pure", "string")
        .then(autoCallbackSpy @thenSpy4, "some error")
        .anyway(autoCallbackSpy @anywaySpy1)
        .then(autoCallbackSpy @thenSpy5, null, "some args")
        .fail @errSpy2

    afterEach ->
      delete @originFnSpy
      delete @errSpy1
      delete @errSpy2
      delete @thenSpy1
      delete @thenSpy2
      delete @thenSpy3
      delete @thenSpy4
      delete @thenSpy5
      delete @anywaySpy1

    it "should exec origin function automatic", ->
      @originFnSpy.called.should.be.true

    it "should call function registered by `then` method before fail", ->
      @thenSpy1.calledWith("a").should.be.true

    it "should pass hole arguments into then function", ->
      @thenSpy2.calledWith("a", "b").should.be.true

    it "should skip when called by empty argument", ->
      @thenSpy3.called.should.be.true

    it "should pass in object to callback what not a function", ->
      @thenSpy4.calledWith("some", "pure", "string").should.be.true

    it "should not call `then` function after error", ->
      @thenSpy5.called.should.be.false

    it "should call function registered by `anyway` method anyway", ->
      @anywaySpy1.called.should.be.true

    it "should call function registered by `fail` method when error", ->
      @errSpy1.calledWith("some error").should.be.true
      @errSpy2.calledWith("some error").should.be.true
