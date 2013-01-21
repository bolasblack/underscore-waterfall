_.mixin
  then: (obj, fn) ->
    if _(fn).isFunction() then fn() else fn
    obj

describe "the underscore waterfall plugin", ->
  beforeEach ->
    @wffnSpy = sinon.spy()
    wffn = (err, args..., callback) =>
      @wffnSpy()
      callback err, args...

    @_wffn = _(wffn).waterfall()

  describe "the waterfall method", ->
    it "should exist", ->
      _.should.have.property "waterfall"

    it "should make original function also callable", ->
      @_wffn()
      @wffnSpy.called.should.be.true

    it "should call function registered by `then` method", ->
      result = @_wffn
      _([0...5]).chain()
        .map ->
          sinon.spy()
        .forEach (spy, index) ->
          result = result.then (err, inputIndex, callback) ->
            spy inputIndex
            callback null, index
        .then =>
          @_wffn 0
        .forEach (spy, index) ->
          spy.called.should.be.true
          spy.calledWith(index).should.be.true

    it "should call function registered by `done` method", ->
      result = @_wffn
      doneSpy = sinon.spy()
      _([0...5]).chain()
        .forEach ->
          result = result.then (err, callback) -> callback()
        .then ->
          result.done doneSpy
        .then =>
          @_wffn()

      doneSpy.called.should.be.true

    it "should call function registered by `fail` method", ->
      result = @_wffn
      failSpy = sinon.spy()
      _([0...5]).chain()
        .forEach (index) ->
          result = result.then (err, callback) ->
            if index is 3
              callback "err"
            else
              callback()
        .then ->
          result.fail failSpy
        .then =>
          @_wffn()

      failSpy.called.should.be.true

    it "should call function registered by `anyway` method when done", ->
      result = @_wffn
      anywaySpy = sinon.spy()
      _([0...5]).chain()
        .forEach ->
          result = result.then (err, callback) -> callback()
        .then ->
          result.anyway anywaySpy
        .then =>
          @_wffn()

      anywaySpy.called.should.be.true

    it "should call function registered by `anyway` method when failed", ->
      result = @_wffn
      anywaySpy = sinon.spy()
      _([0...5]).chain()
        .forEach (index) ->
          result = result.then (err, callback) ->
            if index is 3
              callback "err"
            else
              callback()
        .then ->
          result.anyway anywaySpy
        .then =>
          @_wffn()

      anywaySpy.called.should.be.true
