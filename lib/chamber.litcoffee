    vm = require "vm"
    fs = require "fs"
    assert = require "assert"
    path = require 'path'

Class will allow to share some basic variables, like *path* of the uut, or *options* passed, also generate a path of
**this** file

    class Chamber
      constructor: (@_path, @opts, @illusionFactory) ->
        @physicalLocationOfChamber = path.dirname(/[^\(]*\(([^:]*)/.exec(new Error().stack.split('\n')[1])[1])

      exposeInterior: =>
        illusions = @provokeIllusions()
        return @awokenSelfAwarness(illusions)

      provokeIllusions: =>
        if @opts and @opts.mock
          phantomRelatives = {}
          for relative in @opts.mock
            phantomRelatives[relative] = @projectRelativesAsYouWishedThemToBe(relative)
        return phantomRelatives

      projectRelativesAsYouWishedThemToBe: (rel, reqSubFunction)=>
        reqType = typeof rel
        if reqType is "string"
          if not reqSubFunction
            return @projectWholePerson(rel)

      projectWholePerson: (rel) =>
        if rel[0] == '.' or rel[0] == path.sep
          rel = @compensatePhysicalDistance(rel)
        realRelative = require(rel)
        mockedBehaviors = []
        for relkey,relval of realRelative
          if typeof relval is "function" and relval.name
            mockedBehaviors.push relval.name
        return @illusionFactory(mockedBehaviors...)

      compensatePhysicalDistance: (rel) =>
        return path.relative(@physicalLocationOfChamber, path.join(process.cwd(), path.dirname(@_path), rel))

      awokenSelfAwarness: (mockedRelatives)=>
        wrath = @createInheritedSandbox()
        @replaceRequiresInSandbox(wrath, mockedRelatives)
        context = vm.createContext(wrath);
        script = new vm.Script("module = {exports: {}};" + fs.readFileSync(@_path))
        assert(script.runInContext(context))
        return wrath

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
              return require(path.relative(@physicalLocationOfChamber, path.join(process.cwd(), path.dirname(@_path), p))) #@returnOriginalRequire(p)
            else
              return require(p)

      @returnOriginalRequire: (p) =>
        if p[0] == '.' or p[0] == path.sep
          return require(@compensatePhysicalDistance(p))
        else
          return require(p)

    module.exports = (params...) ->
        new Chamber(params...)

