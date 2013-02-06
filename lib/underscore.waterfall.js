(function() {
  var funcHolder,
    __slice = [].slice;

  funcHolder = function(originArgs) {
    return function() {
      var args, callback, _i;
      args = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), callback = arguments[_i++];
      return callback.apply(null, [null].concat(__slice.call(originArgs)));
    };
  };

  _.mixin({
    waterfall: function(fn) {
      var cacheArgs, callback, calls, metaMethods, stacks, start, thenArgs;
      stacks = {};
      calls = {};
      metaMethods = ["then", "done", "fail", "anyway"];
      thenArgs = [];
      cacheArgs = function(args) {
        args = _(args).toArray();
        if (args.length === 0) {
          return thenArgs.push(void 0);
        } else if (args.length === 1) {
          return thenArgs.push(args[0]);
        } else {
          return thenArgs.push(args);
        }
      };
      start = function() {
        cacheArgs(arguments);
        return fn.apply(null, __slice.call(arguments).concat([callback]));
      };
      callback = function() {
        var args, err, thenFn;
        err = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
        if (err) {
          calls.fail(err);
          calls.anyway(err);
          return;
        }
        if (stacks.then.length) {
          cacheArgs(args);
          thenFn = stacks.then.shift();
          if (typeof thenFn === "function") {
            thenFn.apply(null, __slice.call(args).concat([callback]));
          }
          return;
        }
        calls.done.apply(calls, thenArgs);
        return calls.anyway.apply(calls, [null].concat(__slice.call(thenArgs)));
      };
      _(metaMethods).forEach(function(method) {
        var _ref;
        if ((_ref = stacks[method]) == null) {
          stacks[method] = [];
        }
        start[method] = function(callback) {
          if (_(callback).isFunction()) {
            stacks[method].push(callback);
          } else if (callback) {
            stacks[method].push(funcHolder(_(arguments).toArray()));
          }
          return this;
        };
        return calls[method] = function() {
          var stack, _results;
          stack = stacks[method];
          if (stack == null) {
            return;
          }
          _results = [];
          while (stack.length) {
            fn = stack.shift();
            if (method === "then") {
              _results.push(typeof fn === "function" ? fn.apply(null, __slice.call(arguments).concat([callback])) : void 0);
            } else {
              _results.push(typeof fn === "function" ? fn.apply(null, arguments) : void 0);
            }
          }
          return _results;
        };
      });
      return start;
    },
    deferred: function(fn) {
      var callback, failed, fails, lastArg, lastErr, padding, promise, thens;
      thens = [];
      fails = [];
      padding = false;
      failed = false;
      lastErr = null;
      lastArg = [];
      callback = function() {
        var args, err, failFn, thenFn, type, _ref;
        err = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
        if (err) {
          lastErr = err;
          failed = true;
          while (fails.length) {
            failFn = fails.shift();
            if (typeof failFn === "function") {
              failFn(err);
            }
          }
        }
        while (thens.length) {
          _ref = thens.shift(), thenFn = _ref.fn, type = _ref.type;
          if (!failed || type === "anyway") {
            if (typeof thenFn === "function") {
              thenFn.apply(null, __slice.call(args).concat([callback]));
            }
            break;
          }
        }
        if (padding === "then") {
          lastArg = args;
        }
        return padding = false;
      };
      promise = function() {
        var obj;
        obj = {
          fail: function(fn) {
            if (!fn) {
              return _.clone(promise);
            }
            if (failed) {
              fn(lastErr);
            } else {
              fails.push(fn);
            }
            return promise();
          }
        };
        _.forEach(["then", "anyway"], function(type) {
          return obj[type] = function(fn) {
            if (fn == null) {
              return promise();
            }
            if (failed && type === "then") {
              return promise();
            }
            if (!_(fn).isFunction()) {
              fn = funcHolder(_(arguments).toArray());
            }
            if (padding) {
              thens.push({
                fn: fn,
                type: type
              });
            } else {
              padding = type;
              fn.apply(null, __slice.call(lastArg).concat([callback]));
            }
            return promise();
          };
        });
        return obj;
      };
      return promise().then(fn);
    }
  });

}).call(this);
