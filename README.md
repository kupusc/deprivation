# Sandboxify

This module gives you a full access to an *Unit Under Test* without the need to export everything in order to test it.

This is useful e.g. in *TDD* way of working, or when you want to mock/stub/etc. module dependencies.

Behind the curtains it uses node's VM module.

## Usage

`npm install sandboxify`

Assuming the implementation looks like this:

    var glob = require("glob")

    var myPrivateFunc = function(param){
        return glob.GlobSync(param);
    }

    var myFunc = function(param) {
        return myPrivateFunc(param);
    }

    module.exports.publicFunc = myFunc;

### Basic

in a test file:

    var sandboxify = require("sandboxify");
    uut = sandboxify("./implementation.js");

    uut.publicFunc("blabla"); // nothing special. Will call private func, which calls the original original glob.GlobSync.
    uut.myPrivateFunc("blabla"); // However... note that this func is not exported, but still accessible in a test!
    uut.glob.GlobSync("blabla") // or even this...

### Replace dependencies

    var sandboxify = require("sandboxify");

    uut = sandboxify("./implementation.js");

    uut.glob.GlobSync = function(){};

    // will call the dummy function, and return "undefined" in each case
    uut.publicFunc("blabla");
    uut.myPrivateFunc("blabla");
    uut.glob.GlobSync("blabla");

### API

The module delivers a `mocker` field, which allows you to bind any mocking framework.

The mocking framework must deliver the following interface:

    var sandboxify = require("sandboxify");
    sandboxify.mocker = require("myMockingFramework");

    uut = sandboxify("./implementation.js", mock:["glob"]);

    uut.glob.GlobSync("blabla") // will trigger mock failure -> unexpected call

