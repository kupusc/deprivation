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

*_illusionFactory* is used to produce *Test Doubles*, it is taken from the global parameter, exposed by the package.
 > it means, it can be set from the outside! See below the accepts method of the module's exported properties

        _illusionFactory = stimulation
        _physicalLocationOfChamber = path.dirname(/[^\(]*\(([^:]*)/.exec(new Error().stack.split('\n')[1])[1])

The main and the only public method for usage, after creation of an instance.

      exposeInterior: =>
        return awokenConsciousness(provokeIllusions())

With the mocked dependant modules (optional), this method does the actual trick.
 > It is a wrapper of the node's VM module

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

**The rest of methods is not used in the public branch of the package.** That part is devoted to the automated mocking of dependant modules.

If required (via the *"replace"* option), automatic mocks of dependencies are created.

      provokeIllusions = =>
        if _opts and _opts.replace
          imaginedRelations = {}
          for relation in _opts.replace
            imaginedRelations[relation] = projectRelationsYourWay(relation)
        return imaginedRelations

      replaceRealRelations = (consciousness, _mockedRelations) =>
        consciousness.require = (p)=>
          if _mockedRelations and _mockedRelations[p]
            return _mockedRelations[p]
          else
            if p[0] == '.' or p[0] == path.sep
              return require(path.relative(_physicalLocationOfChamber, path.join(process.cwd(), path.dirname(_path), p))) #@returnOriginalRequire(p)
            else
              return require(p)

By default, the entire module is mocked, but it's open for a possibility to mock automatically only a part of an object, in the future.

      projectRelationsYourWay = (rel, relationAspect) =>
        reqType = typeof rel
        if reqType is "string"
          if not relationAspect
            return projectEntireRelation(rel)

These methods realize mocking of an entire module.

      projectEntireRelation = (rel) =>
        originalName = rel
        rel = compensatePhysicalDistance(rel)
        realSubject = require(rel)
        return mockSubject(realSubject, originalName)

      mockSubject = (subject) =>
        mockedAspects = []
        for relkey,relval of subject
          if typeof relval is "function" and relval.name
            mockedAspects.push relval.name

Note that this is actually the place where the injected mocking framework is used.

        return _illusionFactory(mockedAspects...)

A helper function. It recalculates the relative paths, so that if they are provided here to the require it still works.

      compensatePhysicalDistance = (rel) =>
        improvedRelation = rel
        if rel[0] == '.' or rel[0] == path.sep
          improvedRelation =  path.relative(_physicalLocationOfChamber, path.join(process.cwd(), path.dirname(_path), rel))
        return improvedRelation

A global module's property. Together with the setter methos (see *accepts* below), it realizes a requirement, that once
we set a mocker function in the module, it is used all the time.
Couldn't work out quickly a cleaner solution, but I'm sure it must exist...

    stimulation = undefined

    module.exports = {
      chamber: (params...) =>
        new Chamber(params...)
      accepts: (something) ->
        stimulation = something
    }

