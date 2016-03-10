# Deprivation

This module facilitate *whitebox* and *blackbox* testing (binding it with conventional UT and MT paradigms) of *nodejs* applications.

- *whitebox unit*
  - 'grants' a full access to an object, without the need to export everything in order to test it.
    useful e.g. in *TDD* (test small increments without exposing every method), and writing fine-grained tests.
  - can automatically mock other implementations
  - useless (?) in module tests
  - probably makes more problems in mature projects
- *blackbox module*
  - gives a *normal* access to an object
  - can automatically mock other implementations

 > Behind the curtains it uses the *Node*'s *VM* module, proxyquire, and plows the *require.cache*.

## Usage

```bash
npm install deprivation
cd node_modules/deprivation
npm test
```


Example implementation (*Unit Under Test*).

```javascript
    var glob = require('glob');
    var dep = require('./dep.js');

    var myPrivateFunc = function(param){
        return glob.GlobSync(param);
    }

    var callAnotherGlob = function() {
        return dep('huhu');
    }

    module.exports.publicFunc = function(param) {
        return myPrivateFunc(param);
    };
```

### Basic

An example test file.

```javascript
    var chamber = require("deprivation").chamber;
    var session = chamber("./implementation.js");
    var uut = session.whitebox();
    // uut - Unit Under Test

    uut.publicFunc("blabla"); // nothing special. Will call private func, which calls the original glob.GlobSync.
    uut.myPrivateFunc("blabla"); // However... note that this func is not exported, but still accessible in a test!
    uut.glob.GlobSync("blabla") // or even this...
```

### Replace dependencies

It's possible to inject any type of a test double: *mock*, *spy*, *stub*, *fake*, etc., into the *UUT*.


Example dependency of *UUT*.
```javascript
    // dep.js
    module.exports = require('glob').GlobSync;
```



#### Right after the module is 'loaded'

 - the UUT code is 'loaded' (= all the *require* statements are executed in the *UUT*)
 - the dependencies are replaced after exposition of the *UUT*
 - replacement in not transitive!

```javascript
// let's get rid of glob.GlobSync dependency
    uut.glob.GlobSync = function(){};

// all calls execute the dummy function
    uut.publicFunc('blabla');
    uut.myPrivateFunc('blabla');
    uut.glob.GlobSync('blabla');

// ...but not this one!
    uut.callAnotherGlob();

```

#### Through an option

Leads to a different result:
 - require initialization code of the dependency is not executed
 - replacement is transitive

```javascript
    var myGlob = {GlobSync: function() {return './.ssh/id_rsa.priv'}}
    var session = chamber('./implementation.js', {replace:[{'glob': myGlob}]});
    var uut = session.whitebox();

    // all calls return './.ssh/id_rsa.priv'
    uut.glob.GlobSync('something');
    uut.callAnotherGlob('something');
```

Refer to the *test/chamberTest.coffee* for more examples.
