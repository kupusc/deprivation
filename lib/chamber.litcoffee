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
      _theZeroConditionPath = undefined
      _theZeroConditionContext = undefined

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
        _theZeroConditionPath = undefined
        _theZeroConditionContext = undefined

        _physicalLocationOfChamber = path.dirname(/[^\(]*\(([^:]*)/.exec(new Error().stack.split('\n')[1])[1])
        _path = ipath

        if iopts?.replace
          normalizeReplacements(iopts.replace)

        _opts = iopts

        _betterIllusionFactory = iopts?.replacer

        if(_replacementIds.length or _automaticReplacement) and not _betterIllusionFactory
          throw new Error('if you specify full modules in the \'replace\' option, please specify the \'replacer\' as well')

      blackbox: =>
        @whitebox().module.exports

      whitebox: =>
        invalidateCache()
        _theZeroConditionPath = _path
        _theZeroConditionContext = wakeUp()
        _path = _theZeroConditionPath
        processCache()
        _theZeroConditionContext

      exposeInterior: =>
        cl 'Deprecated! Use the \'whitebox\' method instead!'
        @whitebox()

      getTestDoubles: =>
        _caveImaginedOutsiders

      wakeUp = =>
        c = ->
        c.prototype = global
        context = new c
        situation = vm.createContext(context);
        replaceRequire(context)
        role = new vm.Script("module = {exports: {}};" + fs.readFileSync(_path))
        assert(role.runInContext(situation))
        context

      proxyquireReplacementObjs = (p)=>
        require(p)

      invalidateCache = =>
        for k,v of require.cache
          delete require.cache[k]

      processCache = =>
        processCacheWithAutomocking()
        processCacheWithIds()
        processCacheWithObjs()

      processCacheWithAutomocking = =>
        switch _automaticReplacement
          when 'module' then seekAndReplaceAllImplsNotFromMyFolder()
          when 'ultimate' then seekAndReplaceAllImplsNotFromNodeModules()

      processCacheWithIds = =>
        for i in _replacementIds
          if not require.cache[i]
            require.cache[i] = exports: {}
          normRelativePath = path.relative(process.cwd(), normalizePath(i))
          if not _caveImaginedOutsiders[normRelativePath]
            _betterIllusionFactory(require.cache[i].exports)
            _caveImaginedOutsiders[normRelativePath] = require.cache[i].exports

      processCacheWithObjs = =>
        for k,v of _replacementObjects
          normRelativePath = path.relative(process.cwd(), normalizePath(k))
          if not _caveImaginedOutsiders[normRelativePath]
            require.cache[k].exports = _replacementObjects[k]
            _caveImaginedOutsiders[normRelativePath] = require.cache[k].exports

      normalizeReplacements = (replacements)=>
        for replacement in replacements
          switch typeof replacement
            when 'string' then normalizeReplacementsString(replacement)
            when 'object' then normalizeReplacementsObject(replacement)

      normalizeReplacementsString = (replacement)=>
        switch replacement
          when '../*' then _automaticReplacement = 'module'
          when '*' then _automaticReplacement = 'ultimate'
          else _replacementIds.push(normalizePath(replacement))

      normalizeReplacementsObject = (replacement)=>
        for k,v of replacement
          _replacementObjects[normalizePath(k)] = v
          _replacementObjectsWithOriginalPaths[k] = v

      normalizePath = (p) =>
        require.resolve(compensatePhysicalDistance(p))

      seekAndReplaceAllImplsNotFromNodeModules = =>
        for k,v of require.cache
          if isNotFromNModules(k)
            _replacementIds.push(k)

      seekAndReplaceAllImplsNotFromMyFolder = =>
        for k,v of require.cache
          if isNotFromMyFolder(k)
            _replacementIds.push(k)

      replaceRequire = (context) =>
        context.require = (p)=>
          normalizedP = normalizePath(p)
          #cl normalizedP
          if _replacementObjects and _replacementObjects[normalizedP]
            _replacementObjects[normalizedP]
          else
            #if normalizedP not in (_replacementIds)
              newPath = require.resolve(compensatePhysicalDistance(p))
              if newPath is normalizedP # if after resolve it is still the same, it means it is node native module, not from the node_modules
                require(compensatePhysicalDistance(p))
              else
                if newPath is _theZeroConditionPath
                  return _theZeroConditionContext
                _path = newPath
                #cl _path
                wakeUp().module.exports
            #else
              #require(compensatePhysicalDistance(p))

A helper function. It recalculates the relative paths, so that if they are provided here to the require it still works.

      compensatePhysicalDistance = (rel) =>
        if isRelative(rel)
          require.resolve(path.relative(_physicalLocationOfChamber, path.join(process.cwd(), path.dirname(_path), rel)))
        else
          rel

      isRelative = (path)=>
        path[0] in ['.', path.sep, '..']

      isNotFromMyFolder = (p)->
        myFolder = path.resolve(path.dirname(_path))
        p.search(myFolder) != 0 and isNotFromNModules(p)

      isNotFromNModules = (p)->
        myFolder = path.resolve(path.dirname(_path))
        modulesFolder = path.join(process.cwd(), 'node_modules')
        p.search(modulesFolder) != 0 and p.search(process.cwd()) >= 0 and p != path.resolve(_path)

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

