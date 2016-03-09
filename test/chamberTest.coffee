expect = require("chai").expect
inquisitor = require "@nokia/inquisitor"
glob = require('glob')

myIllusions = inquisitor.createMockObject
deprivation = require "../"
chamber = deprivation.chamber
deprivation.desires(inquisitor.mockify)

xdescribe 'inquisitor playground', ->
  it 'mocks function', ->
    func = -> return 'something'
    inquisitor.mockify(func)

    expect(func()).equal('nothing')


describe "deprivation chamber for UT", ->

  it "exposes my interior", ->
    seance = chamber("test/exampleUUT.js")
    me = seance.exposeInterior()
    expect(me.arrangeHeapDumps).be.ok
    me.arrangeHeapDumps("kupadupa")
    me.module.exports.NoRefFunc()

  it "provides illusions", ->
    seance = chamber("test/exampleUUT.js", replace:["glob"])
    me = seance.exposeInterior()
    mocks = seance.getReplacements()
    inquisitor.expect(mocks['node_modules/glob/glob.js'].GlobSync).once.args("kupadupa")
    inquisitor.expect(me.glob.GlobSync).once.args("jajaja")
    inquisitor.expect(me.glob.GlobSync).once.args("dep.js")
    inquisitor.expect(me.glob.GlobSync).once.args("jojo")
    inquisitor.expect(me.glob.glob).once.args("bleble")
    inquisitor.expect(mocks['node_modules/glob/glob.js'].GlobSync).once.args("dep.js")

    me.arrangeHeapDumps("kupadupa")
    me.module.exports.NoRefFunc()
    me.anotherGlob.NoRefFunc()
    me.anotherGlobCalledViaNextStageDep("dupakupa")

  it "provides relative illusions", ->
    seance = chamber("test/exampleUUT.js", replace:["./dep"])
    me = seance.exposeInterior()
    mocks = seance.getReplacements()
    inquisitor.expect(me.anotherGlob.secondStageGlobSync).once.args("dupakupa")
    inquisitor.expect(mocks['test/dep.js'].NoRefFunc).once
    me.anotherGlobCalledViaNextStageDep("dupakupa")

  it "must not mix mocks with the same names from different modules", ->
    seance = chamber("test/exampleUUT.js", replace:["glob", './dep.js'])
    me = seance.exposeInterior()
    mocks = seance.getReplacements()
    seq = new inquisitor.Sequence()
    inquisitor.expect(me.glob.GlobSync).once.args("dupakupa").in(seq)
    inquisitor.expect(me.anotherGlob.depGlobSync).once.args("dupakupa").in(seq)
    me.glob.GlobSync("dupakupa")
    me.anotherGlob.depGlobSync("dupakupa")

  it 'allows doubles through options', ->
    myGlob = GlobSync: -> return '/.ssh/id_rsa.priv'
    seance = chamber("test/exampleUUT.js", replace:['glob': myGlob])
    me = seance.exposeInterior()
    mocks = seance.getReplacements()
    expect(mocks['node_modules/glob/glob.js'].GlobSync()).to.be.equal('/.ssh/id_rsa.priv')
    expect(mocks['node_modules/glob/glob.js'].glob).to.be.equal(undefined)
    expect(glob.GlobSync('*')).to.be.not.equal('/.ssh/id_rsa.priv')
    expect(me.arrangeHeapDumps('dupakupa')).to.be.equal('/.ssh/id_rsa.priv')

describe 'chamber for MT', ->
  it 'replaces listed packages outside of my dir', ->
    seance = chamber('test/exampleUUT.js', replace:['glob', '../fakePackage/farDependancy'])
    me = seance.enterYourCave()
    mirage = seance.getReplacements()
    inquisitor.expect(mirage['node_modules/glob/glob.js'].GlobSync).once.args('bleble')
    inquisitor.expect(mirage['node_modules/glob/glob.js'].glob).once.args('bleble')
    inquisitor.expect(mirage['node_modules/glob/glob.js'].GlobSync).once.args('jojo')
    inquisitor.expect(mirage['node_modules/glob/glob.js'].GlobSync).once.args('dep.js')
    inquisitor.expect(mirage['fakePackage/farDependancy.js'].caracole).once
    me.arrangeHeapDumps('bleble')
    me.anotherGlobCalledViaNextStageDep() # this is not mocked due to the scope, although the mock './dep' was ordered in the list above
    me.farCall()
    glob.GlobSync('*')

