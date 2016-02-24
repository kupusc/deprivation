    vm = require "vm"
    fs = require "fs"
    assert = require "assert"
    path = require 'path'

Class will allow to share some basic variables, like *path* of the uut, or *options* passed, also generate a path of
**this** file

    class Chamber
      constructor: (@_path, @opts) ->
        @illusionFactory = stimulation
        @physicalLocationOfChamber = path.dirname(/[^\(]*\(([^:]*)/.exec(new Error().stack.split('\n')[1])[1])

      exposeInterior: =>
        return @awokenConsciousness(@provokeIllusions())

      provokeIllusions: =>
        if @opts and @opts.replace
          imaginedRelations = {}
          for relation in @opts.replace
            imaginedRelations[relation] = @projectRelationsYourWay(relation)
        return imaginedRelations

      projectRelationsYourWay: (rel, relationAspect)=>
        reqType = typeof rel
        if reqType is "string"
          if not relationAspect
            return @projectEntireRelation(rel)

      projectEntireRelation: (rel) =>
        rel = @compensatePhysicalDistance(rel)
        realSubject = require(rel)
        mockedSubjects = []
        for relkey,relval of realSubject
          if typeof relval is "function" and relval.name
            mockedSubjects.push relval.name
        return @illusionFactory(mockedSubjects...)

      compensatePhysicalDistance: (rel) =>
        improvedRelation = rel
        if rel[0] == '.' or rel[0] == path.sep
          improvedRelation =  path.relative(@physicalLocationOfChamber, path.join(process.cwd(), path.dirname(@_path), rel))
        return improvedRelation

      awokenConsciousness: (mockedRelations)=>
        consciousness = @wakeUp()
        @replaceRealRelations(consciousness, mockedRelations)
        situation = vm.createContext(consciousness);
        role = new vm.Script("module = {exports: {}};" + fs.readFileSync(@_path))
        assert(role.runInContext(situation))
        return consciousness

      wakeUp: =>
        Awarness = ->
        Awarness.prototype = global
        return new Awarness

      replaceRealRelations: (you, _mockedRelations) =>
        you.require = (p)=>
          if _mockedRelations and _mockedRelations[p]
            return _mockedRelations[p]
          else
            if p[0] == '.' or p[0] == path.sep
              return require(path.relative(@physicalLocationOfChamber, path.join(process.cwd(), path.dirname(@_path), p))) #@returnOriginalRequire(p)
            else
              return require(p)

    stimulation = undefined

    module.exports = {
      chamber: (params...) =>
        new Chamber(params...)
      accepts: (something) ->
        stimulation = something
    }

