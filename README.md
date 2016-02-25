# Deprivation

This module 'grants' the full access to a *Unit Under Test*, without the need to export everything in order to test it.

This is useful e.g. in *TDD* way of working (test small increments without exposing every method), or when one needs to
mock/stub/etc. just anything in his code.

 > Behind the curtains it uses the *Node*'s *VM* module.

## Usage

`npm install deprivation`

`npm test`

Example implementation (*Unit Under Test*).

```javascript
    var glob = require("glob")

    var myPrivateFunc = function(param){
        return glob.GlobSync(param);
    }

    var myFunc = function(param) {
        return myPrivateFunc(param);
    }

    module.exports.publicFunc = myFunc;
```

### Basic

An example test file.

```javascript
    var d = require("deprivation").chamber;
    uut = d("./implementation.js");
    // uut - Unit Under Test

    uut.publicFunc("blabla"); // nothing special. Will call private func, which calls the original glob.GlobSync.
    uut.myPrivateFunc("blabla"); // However... note that this func is not exported, but still accessible in a test!
    uut.glob.GlobSync("blabla") // or even this...
```

### Replace dependencies

An example test file.

```javascript
    var d = require("deprivation").chamber;
    uut = d("./implementation.js");

    // now let's get rid of glob.GlobSync dependency
    uut.glob.GlobSync = function(){};

    uut.publicFunc("blabla");
    uut.myPrivateFunc("blabla");
    uut.glob.GlobSync("blabla");
    // all calls execute the dummy function
```

It's possible inject any type of a test double: *mock*, *spy*, *stub*, *fake*, etc.
