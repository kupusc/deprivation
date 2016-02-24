    vm = require 'vm'
    fs = require 'fs'
    assert = require 'assert'
    path = require 'path'

Class **Chamber** is the main part of the deprivation package.

    class Chamber

Private properties

      _path = undefined
      _opts = undefined
      _illusionFactory = undefined
      _physicalLocationOfChamber = undefined

Instance must be initialized with:
ipath: location of the *Unit Under Test* (mandatory)
iopts: options (see below for details)

      constructor: (ipath, iopts) ->
        _opts = iopts
        _path = ipath

*_illusionFactory* will be used to produce *Test Doubles*, it is taken from the global parameter, exposed by the package.
You can set it with

        _illusionFactory = stimulation
        _physicalLocationOfChamber = path.dirname(/[^\(]*\(([^:]*)/.exec(new Error().stack.split('\n')[1])[1])

      exposeInterior: =>
        return awokenConsciousness(provokeIllusions())

      provokeIllusions = =>
        if _opts and _opts.replace
          imaginedRelations = {}
          for relation in _opts.replace
            imaginedRelations[relation] = projectRelationsYourWay(relation)
        return imaginedRelations

      projectRelationsYourWay = (rel, relationAspect) =>
        reqType = typeof rel
        if reqType is "string"
          if not relationAspect
            return projectEntireRelation(rel)

      projectEntireRelation = (rel) =>
        originalName = rel
        rel = compensatePhysicalDistance(rel)
        realSubject = require(rel)
        return mockSubject(realSubject, originalName)

      mockSubject = (subject) =>
        mockedAspects = []
        for relkey,relval of subject
          #console.log relkey, relval.name
          if typeof relval is "function" and relval.name
            mockedAspects.push relval.name
        return _illusionFactory(mockedAspects...)

      compensatePhysicalDistance = (rel) =>
        improvedRelation = rel
        if rel[0] == '.' or rel[0] == path.sep
          improvedRelation =  path.relative(_physicalLocationOfChamber, path.join(process.cwd(), path.dirname(_path), rel))
        return improvedRelation

      awokenConsciousness = (mockedRelations) =>
        consciousness = wakeUp()
        replaceRealRelations(consciousness, mockedRelations)
        situation = vm.createContext(consciousness);
        role = new vm.Script("module = {exports: {}};" + fs.readFileSync(_path))
        assert(role.runInContext(situation))
        return consciousness

      wakeUp = =>
        Awarness = ->
        Awarness.prototype = global
        return new Awarness

      replaceRealRelations = (consciousness, _mockedRelations) =>
        consciousness.require = (p)=>
          if _mockedRelations and _mockedRelations[p]
            return _mockedRelations[p]
          else
            if p[0] == '.' or p[0] == path.sep
              return require(path.relative(_physicalLocationOfChamber, path.join(process.cwd(), path.dirname(_path), p))) #@returnOriginalRequire(p)
            else
              return require(p)

    stimulation = undefined

    module.exports = {
      chamber: (params...) =>
        new Chamber(params...)
      accepts: (something) ->
        stimulation = something
    }

