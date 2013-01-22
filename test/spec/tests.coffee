_.mixin
  then: (obj, fn) ->
    if _(fn).isFunction() then fn() else fn
    obj

describe "the underscore waterfall plugin", ->
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

  describe "the waterfall method", ->
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
