# Sandboxify

This module 'grants' the full access to a *Unit Under Test*, without the need to export everything in order to test it.

This is useful e.g. in *TDD* way of working (test small increments without exposing every method), or when you want to

mock/stub/etc. module dependencies.

Behind the curtains it uses the *Node*'s *VM* module.

## Usage

`npm install sandboxify`

Example implementation (*Unit Under Test*).

    var glob = require("glob")

    var myPrivateFunc = function(param){
        return glob.GlobSync(param);
    }

    var myFunc = function(param) {
        return myPrivateFunc(param);
    }

    module.exports.publicFunc = myFunc;

### Basic

An example test file.

    var sandboxify = require("sandboxify");
    uut = sandboxify.sandboxify("./implementation.js");

    uut.publicFunc("blabla"); // nothing special. Will call private func, which calls the original original glob.GlobSync.
    uut.myPrivateFunc("blabla"); // However... note that this func is not exported, but still accessible in a test!
    uut.glob.GlobSync("blabla") // or even this...

### Replace dependencies

An example test file.

    var sandboxify = require("sandboxify");

    uut = sandboxify.sandboxify("./implementation.js");

    uut.glob.GlobSync = function(){};

    // will call the dummy function, and return "undefined" in each case
    uut.publicFunc("blabla");
    uut.myPrivateFunc("blabla");
    uut.glob.GlobSync("blabla");

### API

The module delivers a `setTransform` function, which exposes the function used for transforming the production code.

The mocking framework must fulfill a requirement:
 - given a list of function names, must return a module with functions with the same names.
 The new functions are your replacements, can be mocks, stubs, spies, fakes, etc.

    var sandboxify = require("sandboxify");

    myCustomMockingFunction = function(namedFunctions) {
        // whole logic is here, what to do with which
        var stubs = {
            GlobSync: function() {
                console.log "#!@$!@";
            }
        }
        var doubles = {};
        namedFunctions.filter(function(item) {
            if(stubs[item]) {
                doubles[item] = stubs[item];
            } else {
                doubles[item] = function(){};
            }
        });
        return doubles;
    }

    sandboxify.setTransform(myCustomMockingFunction);

    uut = sandboxify("./implementation.js", mock:["glob"]);

    uut.glob.GlobSync("blabla") // myCustomMockingFunction given a list of functions from glob, returns a replacement
                                // 'glob' object with my custom functions

