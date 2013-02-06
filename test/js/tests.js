(function() {
  var autoCallbackSpy,
    __slice = [].slice;

  _.mixin({
    then: function(obj, fn) {
      if (_(fn).isFunction()) {
        fn();
      } else {
        fn;

      }
      return obj;
    }
  });

  autoCallbackSpy = function() {
    var args, err, spy;
    spy = arguments[0], err = arguments[1], args = 3 <= arguments.length ? __slice.call(arguments, 2) : [];
    return function() {
      var callArgs, callback, _i;
      callArgs = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), callback = arguments[_i++];
      spy.apply(null, callArgs);
      return callback.apply(null, [err].concat(__slice.call(args)));
    };
  };

  describe("the underscore waterfall plugin", function() {
    describe("the _.waterfall method", function() {
      beforeEach(function() {
        var _this = this;
        this.doneSpy = sinon.spy();
        this.anywaySpy1 = sinon.spy();
        _.waterfall(function(arg1, callback) {
          _this.originalArg = arg1;
          return callback(null, "some args");
        }).then(function(arg1, callback) {
          _this.thenFn1Arg = arg1;
          return callback(null, "args1", "args2");
        }).then(function(arg1, arg2, callback) {
          _this.thenFn2Arg1 = arg1;
          _this.thenFn2Arg2 = arg2;
          return callback(null, "some other args");
        }).then("straight", "passin", "arguments").then(function(arg1, arg2, arg3, callback) {
          _this.thenFn4Arg1 = arg1;
          _this.thenFn4Arg2 = arg2;
          _this.thenFn4Arg3 = arg3;
          return callback();
        }).done(function() {
          var args;
          args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
          _this.doneArgs = args;
          return _this.doneSpy.apply(_this, args);
        }).anyway(this.anywaySpy1)("first function args");
        this.failSpy = sinon.spy();
        this.anywaySpy2 = sinon.spy();
        return _.waterfall(function(callback) {
          return callback();
        }).then().then(function(callback) {
          _this.thenFn5Called = true;
          return callback();
        }).then(function(callback) {
          return callback("some error message", "other", "args");
        }).fail(this.failSpy).anyway(this.anywaySpy2)();
      });
      afterEach(function() {
        delete this.originalArg;
        delete this.thenFn1Arg;
        delete this.thenFn2Arg1;
        delete this.thenFn2Arg2;
        delete this.thenFn4Arg1;
        delete this.thenFn4Arg2;
        delete this.thenFn4Arg3;
        delete this.doneArgs;
        delete this.doneSpy;
        delete this.failSpy;
        delete this.anywaySpy1;
        delete this.anywaySpy2;
        return delete this.thenFn5Called;
      });
      it("should make original function also callable", function() {
        return this.originalArg.should.equal("first function args");
      });
      it("should call function registered by `then` method", function() {
        this.thenFn1Arg.should.equal("some args");
        this.thenFn2Arg1.should.equal("args1");
        return this.thenFn2Arg2.should.equal("args2");
      });
      it("should pass in object to callback what not a function", function() {
        this.thenFn4Arg1.should.equal("straight");
        this.thenFn4Arg2.should.equal("passin");
        return this.thenFn4Arg3.should.equal("arguments");
      });
      it("should call function registered by `done` method", function() {
        return this.doneSpy.calledWith("first function args", "some args", ["args1", "args2"], "some other args", ["straight", "passin", "arguments"]).should.be["true"];
      });
      it("should skip when called by empty argument", function() {
        return this.thenFn5Called.should.be["true"];
      });
      it("should call function registered by `fail` method", function() {
        return this.failSpy.calledWith("some error message").should.be["true"];
      });
      it("should call function registered by `anyway` method when done", function() {
        return this.anywaySpy1.calledWith(null, "first function args", "some args", ["args1", "args2"], "some other args", ["straight", "passin", "arguments"]).should.be["true"];
      });
      return it("should call function registered by `anyway` method when failed", function() {
        return this.anywaySpy2.calledWith("some error message").should.be["true"];
      });
    });
    return describe("the _.deferred method", function() {
      beforeEach(function() {
        this.originFnSpy = sinon.spy();
        this.errSpy1 = sinon.spy();
        this.errSpy2 = sinon.spy();
        this.thenSpy1 = sinon.spy();
        this.thenSpy2 = sinon.spy();
        this.thenSpy3 = sinon.spy();
        this.thenSpy4 = sinon.spy();
        this.thenSpy5 = sinon.spy();
        this.anywaySpy1 = sinon.spy();
        return _(autoCallbackSpy(this.originFnSpy, null, "a")).deferred().then(autoCallbackSpy(this.thenSpy1, null, "a", "b")).fail(this.errSpy1).then(autoCallbackSpy(this.thenSpy2)).then().then(autoCallbackSpy(this.thenSpy3)).then("some", "pure", "string").then(autoCallbackSpy(this.thenSpy4, "some error")).anyway(autoCallbackSpy(this.anywaySpy1)).then(autoCallbackSpy(this.thenSpy5, null, "some args")).fail(this.errSpy2);
      });
      afterEach(function() {
        delete this.originFnSpy;
        delete this.errSpy1;
        delete this.errSpy2;
        delete this.thenSpy1;
        delete this.thenSpy2;
        delete this.thenSpy3;
        delete this.thenSpy4;
        delete this.thenSpy5;
        return delete this.anywaySpy1;
      });
      it("should exec origin function automatic", function() {
        return this.originFnSpy.called.should.be["true"];
      });
      it("should call function registered by `then` method before fail", function() {
        return this.thenSpy1.calledWith("a").should.be["true"];
      });
      it("should pass hole arguments into then function", function() {
        return this.thenSpy2.calledWith("a", "b").should.be["true"];
      });
      it("should skip when called by empty argument", function() {
        return this.thenSpy3.called.should.be["true"];
      });
      it("should pass in object to callback what not a function", function() {
        return this.thenSpy4.calledWith("some", "pure", "string").should.be["true"];
      });
      it("should not call `then` function after error", function() {
        return this.thenSpy5.called.should.be["false"];
      });
      it("should call function registered by `anyway` method anyway", function() {
        return this.anywaySpy1.called.should.be["true"];
      });
      return it("should call function registered by `fail` method when error", function() {
        this.errSpy1.calledWith("some error").should.be["true"];
        return this.errSpy2.calledWith("some error").should.be["true"];
      });
    });
  });

}).call(this);
