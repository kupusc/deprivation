expect = require("chai").expect
inquisitor = require "@nokia/inquisitor"

myIllusions = inquisitor.createMockObject
deprivation = require "../"
chamber = deprivation.chamber
deprivation.accepts(myIllusions)
deprivation.desires(inquisitor.mockify)
missingModule = 'missing module. I dont want this to crash.': {}


describe "deprivation chamber for UT", ->

  it "exposes my interior", ->
    seance = chamber("test/exampleUUT.js", replace:[missingModule])
    me = seance.exposeInterior()
    expect(me.arrangeHeapDumps).be.ok
    me.arrangeHeapDumps("kupadupa")
    me.module.exports.NoRefFunc()

  it "provides illusions", ->
    seance = chamber("test/exampleUUT.js", replace:["glob", missingModule])
    me = seance.exposeInterior()
    inquisitor.expect(me.glob.GlobSync).once.args("kupadupa")
    inquisitor.expect(me.glob.GlobSync).once.args("jajaja")
    me.arrangeHeapDumps("kupadupa")
    me.module.exports.NoRefFunc()
    me.anotherGlob.NoRefFunc()
    me.anotherGlobCalledViaNextStageDep("dupakupa")

  it "provides relative illusions", ->
    seance = chamber("test/exampleUUT.js", replace:["./dep.js", missingModule])
    me = seance.exposeInterior()
    console.log me.anotherGlob
    inquisitor.expect(me.anotherGlob.secondStageGlobSync).once.args("dupakupa")
    me.anotherGlobCalledViaNextStageDep("dupakupa")

  it "must not mix mocks with the same names from different modules", ->
    seance = chamber("test/exampleUUT.js", replace:["./dep.js", "glob", missingModule])
    me = seance.exposeInterior()
    seq = new inquisitor.Sequence()
    inquisitor.expect(me.glob.GlobSync).once.args("dupakupa").in(seq)
    inquisitor.expect(me.anotherGlob.GlobSync).once.args("dupakupa").in(seq)
    me.glob.GlobSync("dupakupa")
    me.anotherGlob.GlobSync("dupakupa")

  it 'allows doubles through options', ->
    myGlob = GlobSync: -> return '/.ssh/id_rsa.priv'
    seance = chamber("test/exampleUUT.js", replace:["glob": myGlob, missingModule])
    me = seance.exposeInterior()
    expect(me.glob.GlobSync('dupakupa')).to.be.equal('/.ssh/id_rsa.priv')

  it 'makes doubles automatically', ->
    seance = chamber("test/exampleUUT.js", replace: 'all')
    me = seance.exposeInterior()
    inquisitor.expect(me.glob.glob).once.args('dupakupa')
    inquisitor.expect(me.glob.GlobSync).once.args('bleble')
    me.glob.glob("dupakupa")
    me.glob.GlobSync("bleble")

  it 'respects exceptions', ->
    seance = chamber("test/exampleUUT.js", {replace: 'all', except: 'glob'})
    me = seance.exposeInterior()
    me.glob.glob("dupakupa")
    me.glob.GlobSync("bleble")

  it 'respects fine-grained exceptions, lists end everything', ->
    seance = chamber("test/exampleUUT.js", {replace: 'all', except: [{'glob': 'GlobSync'}, './dep.js']})
    me = seance.exposeInterior()
    inquisitor.expect(me.glob.glob).once.args('dupakupa')
    me.glob.glob("dupakupa")
    me.glob.GlobSync("bleble")
    me.anotherGlobCalledViaNextStageDep()

describe 'chamber for MT', ->
  it 'replaces listed packages outside of my dir', ->
    seance = chamber('test/exampleUUT.js', replace:['glob', '../fakePackage/farDependancy', './dep'])
    [me, mirage] = seance.enterYourCave('test')
    inquisitor.expect(mirage['node_modules/glob/glob.js'].GlobSync).once.args('bleble')
    inquisitor.expect(mirage['node_modules/glob/glob.js'].glob).once.args('bleble')
    inquisitor.expect(mirage['node_modules/glob/glob.js'].GlobSync).once.args('jojo')
    inquisitor.expect(mirage['node_modules/glob/glob.js'].GlobSync).once.args('dep.js')
    inquisitor.expect(mirage['fakePackage/farDependancy.js'].caracole).once
    me.arrangeHeapDumps('bleble')
    me.anotherGlobCalledViaNextStageDep() # this is not mocked due to the scope, although the mock './dep' was ordered in the list above
    me.farCall()

