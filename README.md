# underscore.waterfall

```javascript
_.waterfall(function(arg1, callback) {
  callback("some args")
}).then( /* other function */
).done( /* call after "then" function finish */
).fail( /* call when any "then" function error */
).anyway( /* call another done or fail */
)("first function args")
```

```javascript
_.deferred(function(arg1, callback) {
  callback("some args")
}).then( /* other function */
).fail( /* call when any "then" function error */
).anyway( /* call another done or fail */)
```

Read [unit test](https://github.com/bolasblack/underscore-waterfall/blob/master/test/spec/tests.coffee) for more info.
