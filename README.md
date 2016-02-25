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

### API

Ok, this part is poor, but is required to connect to the rest of the mocking system used by my company, which is not public :(

Here it is:
The module exposes `accepts` method, which sets the function used for generation of *test doubles*.

The customized function **is granted**:

 - to be called once per module required by the *UUT*, and given names of functions detected in the module (not recursive)

The customized function **must fulfill**:

 - given names (like: func("a", "b", "c")), should return a module consisting of functions with the same signatures. This module will be used as a replacement by the *UUT*, instead of the original one.
 - called for the second time with the same names (let's say that there are 2 modules with the same method name), it should generate unique *Test Doubles*.

```javascript
    var _ = require("underscore");
    var deprivation = require("deprivation");

    var myIllusions = function() {
        // dumb implementation, just to show the concept
        dummyModule = {}
        _.toArray(arguments).forEach(function(name) {
            dummyModule[name] = function(){};
        })

        return dummyModule;
    }

    deprivation.accepts(myIllusions);

    uut = deprivation.chamber("./implementation.js", replace:["glob"]);

    uut.glob.GlobSync("blabla") // dummy function is called
```
