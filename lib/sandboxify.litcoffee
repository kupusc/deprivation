    vm = require "vm"
    fs = require "fs"
    assert = require "assert"
    path = require 'path'

Class will allow to share some basic variables, like *path* of the uut, or *options* passed, also generate a path of
**this** file

    class Sandbox
      constructor: (@_path, @opts) ->
        @thisFilePath = /[^\(]*\(([^:]*)/.exec(new Error().stack.split('\n')[1])[1]

      giveSandbox: =>
        #thisFilePath = /[^\(]*\(([^:]*)/.exec(new Error().stack.split('\n')[1])[1]
        if @opts and @opts.mock
          mockedRequires = {}
          for req in @opts.mock
            mockedRequires[req] = @mockifyRequirements(req)
        return @createSandboxFromPath(mockedRequires)

      setDoubleMaker: (@doubleMaker) =>

      mockifyRequirements: (req, reqSubFunction)=>
        reqType = typeof req
        if reqType is "string"
          if not reqSubFunction
            return @mockifyRequirmentsWholeModule(req)

      mockifyRequirmentsWholeModule: (req) =>
        if req[0] == '.' or req[0] == path.sep
          @makePathVisibleFromHere(req)
        _module = require(req)
        funcsToBeMocked = []
        for modkey,modval of _module
          if typeof modval is "function" and modval.name
            funcsToBeMocked.push modval.name
        return @doubleMaker(funcsToBeMocked...)

      makePathVisibleFromHere: (req) =>
        console.log 'before transformation: ' + req
        console.log 'after: ', path.join(pathFromCaller, req)

      createSandboxFromPath: (_mockedRequires)=>
        sandbox = @createInheritedSandbox()
        @replaceRequiresInSandbox(sandbox, _mockedRequires)
        context = vm.createContext(sandbox);
        script = new vm.Script("module = {exports: {}};" + fs.readFileSync(@_path))
        assert(script.runInContext(context))
        return sandbox

      createInheritedSandbox: =>
        Sandbox = ->
        Sandbox.prototype = global
        return new Sandbox

      replaceRequiresInSandbox: (sandbox, _mockedRequires) =>
        sandbox.require = (p)=>
          if _mockedRequires and _mockedRequires[p]
            return _mockedRequires[p]
          else
            return @returnRequireOrAssert(p)

      returnRequireOrAssert: (p)=>
        if p[0] == '.' or p[0] == path.sep
          assert false, 'module ' + p + ' must be explicitly doubled with ..., {"' + p + '": aDoubleObject} argument!'
        else
          return require(p)

    module.exports = (params...) -> new Sandbox(params...)
