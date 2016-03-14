    vm = require 'vm'
    fs = require 'fs'
    assert = require 'assert'
    path = require 'path'
    nativeModule = require('module')
    cl = console.log.bind(this, 'chamber.litcoffee ---> ')


Class **Chamber** is the main part of the deprivation package.

    class Chamber

Instance must be initialized with:
ipath: location of the *Unit Under Test* (mandatory)
@_opts: options (see below for details)

      constructor: (@_path, @_opts) ->

        @_testDoubles = {}
        @_doubleIds = []
        @_doubleObjs = {}
        @_doubleObjsWithOrigPaths = {}

        @_getThisFileDir = path.dirname(/[^\(]*\(([^:]*)/.exec(new Error().stack.split('\n')[1])[1])

        if @_opts?.replace
          @_normalizeReplacements(@_opts.replace)

        @_betterIllusionFactory = @_opts?.replacer

        if(@_doubleIds.length or @_automaticReplacement) and not @_betterIllusionFactory
          throw new Error('if you specify full modules in the \'replace\' option, please specify the \'replacer\' as well')

      blackbox: =>
        @whitebox().module.exports

      whitebox: =>
        @_invalidateCache()
        @_theZeroConditionPath = @_path
        @_theZeroConditionContext = @_wakeUp()
        @_path = @_theZeroConditionPath
        @_processCache()
        @_theZeroConditionContext

      exposeInterior: =>
        cl 'Deprecated! Use the \'whitebox\' method instead!'
        @whitebox()

      getTestDoubles: =>
        @_testDoubles

      _wakeUp: =>
        c = ->
        c.prototype = global
        context = new c
        situation = vm.createContext(context);
        @_replaceRequire(context)
        role = new vm.Script("module = {exports: {}};" + fs.readFileSync(@_path))
        assert(role.runInContext(situation))
        context

      _invalidateCache: =>
        for k,v of require.cache
          delete require.cache[k]

      _processCache: =>
        @_processCacheWithAutomocking()
        @_processCacheWithIds()
        @_processCacheWithObjs()

      _processCacheWithAutomocking: =>
        switch @_automaticReplacement
          when 'module' then @_seekAndReplaceAllImplsNotFromMyFolder()
          when 'ultimate' then @_seekAndReplaceAllImplsNotFromNodeModules()

      _processCacheWithIds: =>
        for i in @_doubleIds
          if not require.cache[i]
            require.cache[i] = exports: {}
          normRelativePath = path.relative(process.cwd(), @_normalizePath(i))
          @_betterIllusionFactory(require.cache[i].exports)
          @_testDoubles[normRelativePath] = require.cache[i].exports

      _processCacheWithObjs: =>
        for k,v of @_doubleObjs
          normRelativePath = path.relative(process.cwd(), @_normalizePath(k))
          require.cache[k].exports = @_doubleObjs[k]
          @_testDoubles[normRelativePath] = require.cache[k].exports

      _normalizeReplacements: (replacements)=>
        for replacement in replacements
          switch typeof replacement
            when 'string' then @_normalizeReplacementsString(replacement)
            when 'object' then @_normalizeReplacementsObject(replacement)

      _normalizeReplacementsString: (replacement)=>
        switch replacement
          when '../*' then @_automaticReplacement = 'module'
          when '*' then @_automaticReplacement = 'ultimate'
          else @_doubleIds.push(@_normalizePath(replacement))

      _normalizeReplacementsObject: (replacement)=>
        for k,v of replacement
          @_doubleObjs[@_normalizePath(k)] = v
          @_doubleObjsWithOrigPaths[k] = v

      _normalizePath: (p) =>
        require.resolve(@_fixRelativePath(p))

      _seekAndReplaceAllImplsNotFromNodeModules: =>
        for k,v of require.cache
          if @_isNotFromNModules(k)
            @_doubleIds.push(k)

      _seekAndReplaceAllImplsNotFromMyFolder: =>
        for k,v of require.cache
          if @_isNotFromMyFolder(k)
            @_doubleIds.push(k)

      _replaceRequire: (context) =>
        context.require = (p)=>
          normalizedP = @_normalizePath(p)
          #cl normalizedP
          if @_doubleObjs and @_doubleObjs[normalizedP]
            @_doubleObjs[normalizedP]
          else
            #if normalizedP not in (_doubleIds)
              newPath = require.resolve(@_fixRelativePath(p))
              if newPath is normalizedP # if after resolve it is still the same, it means it is node native module, not from the node_modules
                #cl newPath, normalizedP
                require(@_fixRelativePath(p))
              else
                if newPath is @_theZeroConditionPath
                  return @_theZeroConditionContext
                @_path = newPath
                #cl _path
                @_wakeUp().module.exports
            #else
              #require(_fixRelativePath(p))

A helper function. It recalculates the relative paths, so that if they are provided here to the require it still works.

      _fixRelativePath: (rel) =>
        if @_isRelative(rel)
          require.resolve(path.relative(@_getThisFileDir, path.join(process.cwd(), path.dirname(@_path), rel)))
        else
          rel

      _isRelative: (path)=>
        path[0] in ['.', path.sep]

      _isNotFromMyFolder: (p)->
        myFolder = path.resolve(path.dirname(@_path))
        p.search(myFolder) != 0 and @_isNotFromNModules(p)

      _isNotFromNModules: (p)->
        myFolder = path.resolve(path.dirname(@_path))
        modulesFolder = path.join(process.cwd(), 'node_modules')
        p.search(modulesFolder) != 0 and p.search(process.cwd()) >= 0 and p != path.resolve(@_path)

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

