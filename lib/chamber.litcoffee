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
      _cave = undefined

Instance must be initialized with:
ipath: location of the *Unit Under Test* (mandatory)
iopts: options (see below for details)

      constructor: (ipath, iopts) ->
        _path = ipath

        if iopts?.replace
          compensateGlob(iopts.replace)

        _opts = iopts
        _opts?.except ?= []

*_illusionFactory* is used to produce *Test Doubles*, it is taken from the global parameter, exposed by the package.
 > it means, it can be set from the outside! See below the accepts method of the module's exported properties

        _illusionFactory = stimulation
        _physicalLocationOfChamber = path.dirname(/[^\(]*\(([^:]*)/.exec(new Error().stack.split('\n')[1])[1])

      compensateGlob = (optsIllusions)=>
        for replacementSpec in optsIllusions
          for orig,repl of replacementSpec
            compensated = compensatePhysicalDistance(orig)
            if compensated != orig
              replacementSpec[compensated] = repl
              delete replacementSpec[orig]

The main and the only public method for usage, after creation of an instance.

      exposeInterior: =>
        awokenConsciousness(provokeIllusions())

Cave is your module (folder)

      enterYourCave: (cavePath) =>
        _cave = path.resolve(cavePath)
        p = require.resolve(path.relative(_physicalLocationOfChamber, _path))
        m = require(p)
        processCache()
        m

      processCache = =>
        for k,v of require.cache
          makeDoubleOfIt(k,v) if not isInYourCave(k)

      isInYourCave = (p)=>
        #console.log _cave
        return p.search(_cave) == 0

      makeDoubleOfIt = (k,v) =>
        console.log require.cache[k]

With the mocked dependant modules (optional), this method does the actual trick.
 > It is a wrapper of the node's VM module

      awokenConsciousness = (mockedRelations) =>
        consciousness = new ->
        situation = vm.createContext(consciousness);
        replaceRequire(consciousness, mockedRelations)
        role = new vm.Script("module = {exports: {}};" + fs.readFileSync(_path))
        assert(role.runInContext(situation))
        consciousness

**The rest of methods is not oficially used in the public branch of the package.**
That part is devoted to the automated mocking of dependant modules, if a special *"mocker"* function is provided.
While it suits well to the mocking framework used in my company, it is not in any way more convenient from the
method described in the README.md.
 > In order to use it a mocking framework must be developed.
Releasing our company's mocking framework is under consideration, however the deadline is not known.

If required (via the *"replace"* option), automatic mocks of dependencies are created.

      provokeIllusions = =>
        if _opts?.replace != 'all'
          imaginedRelations = {}
          for relation in [].concat(_opts?.replace)
            if typeof relation is "object"
              for key,val of relation
                imaginedRelations[key] = val
            else
              imaginedRelations[relation] = projectRelationsYourWay(relation)
        imaginedRelations

      replaceRequire = (consciousness, _mockedRelations) =>
        if _opts?.replace == 'all'
          consciousness.require = (p)=>
            original = require(compensatePhysicalDistance(p))
            if p in [].concat(_opts.except)
              replacement = original
            else
              replacement = projectEntireRelation(p)
              for ex in [].concat(_opts.except)
                if typeof ex == 'object'
                  for k,v of ex
                    replacement[v] = original[v]
            replacement
        else
          consciousness.require = (p)=>
            if _mockedRelations and _mockedRelations[p]
              _mockedRelations[p]
            else
              require(compensatePhysicalDistance(p))

By default, the entire module is mocked, but it's open for a possibility to mock automatically only a part of an object, in the future.

      projectRelationsYourWay = (rel, relationAspect) =>
        reqType = typeof rel
        if reqType is "string"
          if not relationAspect
            projectEntireRelation(rel)

These methods realize mocking of an entire module.

      projectEntireRelation = (rel) =>
        mockSubject(require(compensatePhysicalDistance(rel)))

      mockSubject = (subject) =>
        mockedAspects = []
        for relkey,relval of subject
          if typeof relval is "function" and relval.name
            mockedAspects.push relval.name

Note that this is actually the place where the injected mocking framework is used.

        _illusionFactory(mockedAspects...)

A helper function. It recalculates the relative paths, so that if they are provided here to the require it still works.

      compensatePhysicalDistance = (rel) =>
        if isRelative(rel)
          require.resolve(path.relative(_physicalLocationOfChamber, path.join(process.cwd(), path.dirname(_path), rel)))
        else
          rel

      isRelative = (path)=>
        path[0] in ['.', path.sep, '..']
A global module's property. Together with the setter methos (see *accepts* below), it realizes a requirement, that once
we set a mocker function in the module, it is used all the time.
Couldn't work out quickly a cleaner solution, but I'm sure it must exist...

    stimulation = undefined

Module exports. Note the way the stimulation property is used above in the class.
Patches are welcome.

    module.exports = {
      chamber: (params...) =>
        new Chamber(params...)
      accepts: (something) ->
        stimulation = something
    }

