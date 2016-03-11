    vm = require 'vm'
    fs = require 'fs'
    assert = require 'assert'
    path = require 'path'
    cl = console.log.bind(this, 'chamber.litcoffee ---> ')


Class **Chamber** is the main part of the deprivation package.

    class Chamber

      _path = undefined
      _opts = undefined
      _physicalLocationOfChamber = undefined
      _cave = undefined
      _caveImaginedOutsiders = {}
      _replacementIds = []
      _replacementObjects = {}
      _replacementObjectsWithOriginalPaths = {}
      _automaticReplacement = false

This must produce a Test Double out of an object, so that it can be controlled
in tests

      _betterIllusionFactory = undefined

Instance must be initialized with:
ipath: location of the *Unit Under Test* (mandatory)
iopts: options (see below for details)

      constructor: (ipath, iopts) ->

        _path = undefined
        _opts = undefined
        _physicalLocationOfChamber = undefined
        _cave = undefined
        _caveImaginedOutsiders = {}
        _replacementIds = []
        _replacementObjects = {}
        _replacementObjectsWithOriginalPaths = {}
        _automaticReplacement = false

        _physicalLocationOfChamber = path.dirname(/[^\(]*\(([^:]*)/.exec(new Error().stack.split('\n')[1])[1])
        _path = ipath

        if iopts?.replace
          normalizeReplacements(iopts.replace)

        _opts = iopts

        _betterIllusionFactory = iopts?.replacer

        if(_replacementIds.length or _automaticReplacement) and not _betterIllusionFactory
          throw new Error('if you specify full modules in the \'replace\' option, please specify the \'replacer\' as well')

      exposeInterior: =>
        cl 'Deprecated! Use the \'whitebox\' method instead!'
        @exposeInterior()

      whitebox: =>
        consciousness = new ->
        consciousness.console = console
        situation = vm.createContext(consciousness);
        invalidateCache()
        replaceRequire(consciousness)
        role = new vm.Script("module = {exports: {}};" + fs.readFileSync(_path))
        assert(role.runInContext(situation))
        processCache()
        consciousness

      getTestDoubles: =>
        _caveImaginedOutsiders

      blackbox: =>
        @whitebox().module.exports

      proxyquireReplacementObjs = (p)=>
        require(p)

      invalidateCache = =>
        for k,v of require.cache
          delete require.cache[k]

      invalidateRequireCache: =>
        for k,v of _replacementObjects
          delete require.cache[k]
        for i in _replacementIds
          delete require.cache[i]

      processCache = =>
        if _automaticReplacement
          seekAndReplaceAllImplsNotFromNodeModules()
        for i in _replacementIds
          if not require.cache[i]
            require.cache[i] = exports: {}
          normRelativePath = path.relative(process.cwd(), normalizePath(i))
          _betterIllusionFactory(require.cache[i].exports)
          _caveImaginedOutsiders[normRelativePath] = require.cache[i].exports
        for k,v of _replacementObjects
            normRelativePath = path.relative(process.cwd(), normalizePath(k))
            require.cache[k].exports = _replacementObjects[k]
            _caveImaginedOutsiders[normRelativePath] = require.cache[k].exports

      isInYourCave = (p)=>
        return p.search(_cave) == 0

      normalizeReplacements = (replacements)=>
        for replacement in replacements
          if typeof replacement is 'string'
            if replacement is '../*'
              _automaticReplacement = true
            else
              _replacementIds.push(normalizePath(replacement))
          else
            if typeof replacement is 'object'
              for k,v of replacement
                _replacementObjects[normalizePath(k)] = v
                _replacementObjectsWithOriginalPaths[k] = v

      normalizePath = (p) =>
        require.resolve(compensatePhysicalDistance(p))

      seekAndReplaceAllImplsNotFromNodeModules = =>
        for k,v of require.cache
          myFolder = path.resolve(path.dirname(_path))
          modulesFolder = path.join(process.cwd(), 'node_modules')
          if k.search(myFolder) != 0 and k.search(modulesFolder) != 0 and k.search(process.cwd()) >= 0
            _replacementIds.push(k)

      replaceRequire = (consciousness) =>
        consciousness.require = (p)=>
          normalizedP = normalizePath(p)
          if _replacementObjects and _replacementObjects[normalizedP]
            _replacementObjects[normalizedP]
          else
            require(compensatePhysicalDistance(p))

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

    betterStimulation = (real) =>
      return real

Module exports. Note the way the stimulation property is used above in the class.
Patches are welcome.

    module.exports = {
      chamber: (params...) =>
        new Chamber(params...)
      desires: (somethingBetter) ->
        betterStimulation = somethingBetter
    }

