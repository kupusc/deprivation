    vm = require 'vm'
    fs = require 'fs'
    assert = require 'assert'
    path = require 'path'
    cl = console.log.bind(this, 'chamber.litcoffee ---> ')
    RC = require.cache

    class Chamber

      constructor: (@_path, @_opts) ->

        @_testDoubles = {}
        @_doubleIds = []
        @_doubleObjs = {}

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
        context = @_wakeUp()
        @_processCache()
        context

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
        for k,v of RC
          delete RC[k]
        @_testDoubles = {}

      _processCache: =>
        @_automockExtractIds()
        @_processCacheWithIds()
        @_processCacheWithObjs()
        @_dealWithPromises()

      _dealWithPromises: =>
        for key,val of @_testDoubles
          for k,v of val
            if typeof v is 'function' and not (k.match('Async$'))
              val[k + 'Async'] = v


      _automockExtractIds: =>
        switch @_automaticReplacement
          when 'module' then @_seekNotFromMyFolder()
          when 'ultimate' then @_seekNotFromNodeModules()

      _processCacheWithIds: =>
        for i in @_doubleIds
          if RC[i] is undefined
            throw new Error('Remove the module \'' + i + '\' from the \'replace\' option, it is not required anywhere!')
          normRelativePath = path.relative(process.cwd(), @_normalizePath(i))
          if not @_testDoubles[normRelativePath]
            @_betterIllusionFactory(RC[i].exports)
            @_testDoubles[normRelativePath] = RC[i].exports

      _processCacheWithObjs: =>
        for k,v of @_doubleObjs
          if RC[k] is undefined
            throw new Error('Remove the module \'' + k + '\' from the \'replace\' option, it is not required anywhere!')
          normRelativePath = path.relative(process.cwd(), @_normalizePath(k))
          if not @_testDoubles[normRelativePath]
            RC[k].exports = @_doubleObjs[k]
            @_testDoubles[normRelativePath] = RC[k].exports

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

      _normalizePath: (p) =>
        require.resolve(@_fixRelativePath(p))

      _seekNotFromNodeModules: =>
        for k,v of RC
          if @_isNotFromNModules(k)
            @_doubleIds.push(k)

      _seekNotFromMyFolder: =>
        for k,v of RC
          if @_isNotFromMyFolder(k) and @_isNotFromNModules(k)
            @_doubleIds.push(k)

      _replaceRequire: (context) =>
        context.require = (p)=>
          normalizedP = @_normalizePath(p)
          if @_doubleObjs and @_doubleObjs[normalizedP]
            @_doubleObjs[normalizedP]
          else
            require(@_fixRelativePath(p))

      _fixRelativePath: (rel) =>
        if @_isRelative(rel)
          require.resolve(path.relative(@_getThisFileDir, path.join(process.cwd(), path.dirname(@_path), rel)))
        else
          rel

      _isRelative: (path)=>
        path[0] in ['.', path.sep]

      _isNotFromMyFolder: (p)->
        myFolder = path.resolve(path.dirname(@_path))
        p.search(myFolder) != 0

      _isNotFromNModules: (p)->
        myFolder = path.resolve(path.dirname(@_path))
        modulesFolder = path.join(process.cwd(), 'node_modules')
        p.search(modulesFolder) != 0 and p.search(process.cwd()) >= 0

    module.exports = {
      chamber: (params...) =>
        new Chamber(params...)
    }

