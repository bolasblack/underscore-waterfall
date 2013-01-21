# underscore.waterfall

```javascript
_.waterfall(function(err, arg1, callback) {
  callback("some args")
}).then(function(err, arg2, callback) {
  // call at 1st
  assert(arg2, "some args")
}).then( /* ... */ ).done(function(err, finalarg, callback) {
  // call when `thenFn` finish
  callback()
}).done( /* ... */ ).fail(function(err, finalarg, callback) {
  // call when any `thenFn` error
  callback()
}).fail( /* ... */ ).anyway(function(err, finalarg, callback) {
  // call another done or fail
  callback()
}).anyway( /* ... */ )
```
