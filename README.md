# Deprivation

This module facilitate *whitebox* and *blackbox* testing (binding it with conventional UT and MT paradigms) of *nodejs* applications.

 > We define a module as a folder with implementations.

These are the two main **modes** of operation of the deprivation module:

- *whitebox unit*
  - grants a full access to an object, without the need to export everything in order to test it.
    useful e.g. in *TDD* (test small increments without exposing every method), and writing fine-grained tests.

- *blackbox module*
  - gives the *public* access to an object

**Both modes enable auto mocking**.

 > Behind the curtains it uses the *Node*'s *VM* module, and plows the *require.cache*.

## Usage

```bash
npm install deprivation
```
For running a complete suite of tests use the *npm test* command.


Example implementation (*Unit Under Test*).

```javascript
    var glob = require('glob');
    var dep = require('./dep.js');

    var myPrivateFunc = function(param){
        return glob.GlobSync(param);
    };

    var publicFunc = function(param) {
        return myPrivateFunc(param);
    };

    var callAnotherGlob = function() {
        return dep('huhu');
    };

    module.exports.publicFunc = publicFunc;
```

### Basic

An example test file.

```javascript
    var chamber = require("deprivation").chamber;
    var session = chamber("./implementation.js");

    // uut - Unit Under Test
    var uut = session.whitebox();

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
 - if the replacement is an object, the require initialization code of the replaced dependancies is not executed
 - if the replacement is a string (as in the require statement), the require initialization code **is** executed
 - replacement is transitive (it is replaced globally)

```javascript
    var myGlob = {GlobSync: function() {return './.ssh/id_rsa.priv'}}
    var session = chamber('./implementation.js', {replace:[{'glob': myGlob}]});
    var uut = session.whitebox();

    // all calls return './.ssh/id_rsa.priv'
    uut.glob.GlobSync('something');
    uut.callAnotherGlob('something');
```
#### Blackbox, through an option, with more automation

If a function exists, which accepts an object, and returns its *test double*,

```javascript
// A jasmine spy-maker example

    var myReplacer = function (obj) {
        Object.keys(obj).forEach(function (item) {
            spyOn(obj, item);
        });
    };
```
it can be passed on with the *replacer* option.

```javascript
    seance = chamber("myModule/impl.js", {replace: ['glob', '../*'], replacer: myReplacer});
```

In the above example
 - the magical '../\*' string means that all implementations outside of *myModule* folder will be automatically transformed into spies. This omits the *node_module* folder.
 - due to the above, the *glob* package is added explicitly, and will be automatically turned into a mock,

An example test suite (jasmine/mocha):

```javascript
    beforeEach(function () {
        sut = seance.blackbox();
        spies = seance.getTestDoubles();
    });
```
*spies* above are the spy objects references, stored in a dictionary. This allows to work with objects, that are inaccessible from the module's public interface.

The expectation may be set, using the obtained references.

```javascript
    it('uses GlobSync', function () {
        sut.arrangeHeapDumps('bleble');
        expect(spies['node_modules/glob/glob.js'].GlobSync).toHaveBeenCalled();
    });
```

Test doubles are accessed using the path relative to the process current directory. This is the most readable way to specify, which test double object is referenced (the *glob* package may be used by other sub-packages, in different versions, etc.)

 > Clone the project from the repository and refer to the test/\*.\* files for more examples.
