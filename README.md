# Deprivation

This module 'grants' the full access to a *Unit Under Test*, without the need to export everything in order to test it.

This is useful e.g. in *TDD* way of working (test small increments without exposing every method), or when one needs to
mock/stub/etc. just anything in his code.

 > Behind the curtains it uses the *Node*'s *VM* module.

## Usage

```bash
npm install deprivation
cd node_modules/deprivation
npm test
```


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
var deprivation = require("deprivation").chamber;
var session = deprivation("./implementation.js");
var uut = session.exposeInterior();
// uut - Unit Under Test

uut.publicFunc("blabla"); // nothing special. Will call private func, which calls the original glob.GlobSync.
uut.myPrivateFunc("blabla"); // However... note that this func is not exported, but still accessible in a test!
uut.glob.GlobSync("blabla") // or even this...
```

### Replace dependencies

It's possible to inject any type of a test double: *mock*, *spy*, *stub*, *fake*, etc., into the *UUT*

#### Right after the module is 'loaded'

 - the UUT code is 'loaded' (= all the *require* statements are executed in the *UUT*)
 - the dependencies are replaced after exposition of the *UUT*

```javascript
// let's get rid of glob.GlobSync dependency
    uut.glob.GlobSync = function(){};

    uut.publicFunc('blabla');
    uut.myPrivateFunc('blabla');
    uut.glob.GlobSync('blabla');
// all calls execute the dummy function
```

#### Without an actual execution of the *require* statements

Sometimes it is desired to replace dependancies in the *UUT* without even trying to actually *require* them.

This has the following advantages:
 - speed up of an execution of tests,
 - complete independence from other modules:
   - no risk that something is executed in the global scope (can potentially introduce dependencies between tests),
   - will work even if the module is missing.

```javascript
    var deprivation = require('deprivation').chamber;
    var myGlob = {GlobSync: function() {return '/.ssh/id_rsa.priv'}}
    var session = deprivation('./implementation.js', {replace:[{'glob': myGlob]}});
    var uut = session.exposeInterior();
    expect(uut.glob.GlobSync('something')).to.be.equal('/.ssh/id_rsa.priv')
```

Refer to the *test/chamberTest.coffee* for more examples.
