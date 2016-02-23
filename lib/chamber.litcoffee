    vm = require "vm"
    fs = require "fs"
    assert = require "assert"
    path = require 'path'

Class will allow to share some basic variables, like *path* of the uut, or *options* passed, also generate a path of
**this** file

    class Chamber
      constructor: (@_path, @opts, @illusionFactory) ->
        @thisFileDir = path.dirname(/[^\(]*\(([^:]*)/.exec(new Error().stack.split('\n')[1])[1])

      giveImpression: =>
        #thisFilePath = /[^\(]*\(([^:]*)/.exec(new Error().stack.split('\n')[1])[1]
        if @opts and @opts.mock
          mockedRequires = {}
          for req in @opts.mock
            mockedRequires[req] = @mockifyRequirements(req)

        #console.log mockedRequires

        return @createSandboxFromPath(mockedRequires)

      mockifyRequirements: (req, reqSubFunction)=>
        reqType = typeof req
        if reqType is "string"
          if not reqSubFunction
            return @mockifyRequirmentsWholeModule(req)

      mockifyRequirmentsWholeModule: (req) =>
        if req[0] == '.' or req[0] == path.sep
          req = @makePathVisibleFromHere(req)
        _module = require(req)
        funcsToBeMocked = []
        for modkey,modval of _module
          #console.log 'modkey: ' + modkey + ', modval:' + modval + ', typeof modval: ' + typeof modval + ', modval.name:' + modval.name
          if typeof modval is "function" and modval.name
            #console.log modval.name
            funcsToBeMocked.push modval.name
        return @illusionFactory(funcsToBeMocked...)

      makePathVisibleFromHere: (req) =>
        #console.log 'before transformation: ' + req
        resultingPath = path.relative(@thisFileDir, path.join(process.cwd(), path.dirname(@_path), req))
        #console.log 'after: ', resultingPath
        return resultingPath

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
            if p[0] == '.' or p[0] == path.sep
              return require(path.relative(@thisFileDir, path.join(process.cwd(), path.dirname(@_path), p))) #@returnOriginalRequire(p)
            else
              return require(p)

      @returnOriginalRequire: (p) =>
        if p[0] == '.' or p[0] == path.sep
          return require(@makePathVisibleFromHere(p))
        else
          return require(p)

    module.exports = (params...) ->
        new Chamber(params...)

