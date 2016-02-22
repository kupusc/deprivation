


    vm = require "vm"
    fs = require "fs"
    inquisitor = require "@nokia/inquisitor"
    assert = require "assert"

    module.exports = (_path, opts) ->
      if opts and opts.mock
        mockedRequires = {}
        for req in opts.mock
          mockedRequires[req] = mockifyRequirements(req)
      return createSandboxFromPath(_path, mockedRequires)

    mockifyRequirements = (req, reqSubFunction)->
      reqType = typeof req
      if reqType is "string"
        if not reqSubFunction
          return mockifyRequirmentsWholeModule(req)

    mockifyRequirmentsWholeModule = (req) ->
      module = require(req)
      funcsToBeMocked = []
      for modkey,modval of module
        if typeof modval is "function" and modval.name
          funcsToBeMocked.push modval.name
      return inquisitor.makeGlobalMock(funcsToBeMocked...)

    createSandboxFromPath = (p, _mockedRequires)->
      sandbox = createInheritedSandbox
      replaceRequiresInSandbox(sandbox, _mockedRequires)
      context = vm.createContext(sandbox);
      script = new vm.Script("module = {exports: {}};" + fs.readFileSync(p))
      assert(script.runInContext(context))
      return sandbox

    createInheritedSandbox = ->
      Sandbox = ->
      Sandbox.prototype = global
      return new Sandbox

    replaceRequiresInSandbox = (sandbox, _mockedRequires) ->
      sandbox.require = (p)->
        if _mockedRequires and _mockedRequires[p]
          return _mockedRequires[p]
        else
          return require(p)
