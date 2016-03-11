expect = require("chai").expect
glob = require('glob')

deprivation = require "../"
chamber = deprivation.chamber
inquisitor = require "@nokia/inquisitor"
cl = console.log.bind(this, 'chamberTest.coffee --->')
#
#
describe "deprivation chamber for UT", ->

  it "exposes my interior", ->
    me = chamber("test/exampleUUT.js").whitebox()
    expect(me.arrangeHeapDumps).be.ok
    me.arrangeHeapDumps("kupadupa")
    me.module.exports.NoRefFunc()

  it "provides illusions", ->
    seance = chamber("test/exampleUUT.js", replace:["glob"], replacer: inquisitor.mockify)
    me = seance.whitebox()
    mocks = seance.getTestDoubles()
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
    seance = chamber("test/exampleUUT.js", replace:["./dep"], replacer: inquisitor.mockify)
    me = seance.whitebox()
    mocks = seance.getTestDoubles()
    inquisitor.expect(me.anotherGlob.secondStageGlobSync).once.args("dupakupa")
    inquisitor.expect(mocks['test/dep.js'].NoRefFunc).once
    me.anotherGlobCalledViaNextStageDep("dupakupa")

  it "must not mix mocks with the same names from different modules", ->
    me = chamber("test/exampleUUT.js", replace:["glob", './dep.js'], replacer: inquisitor.mockify).whitebox()
    seq = new inquisitor.Sequence()
    inquisitor.expect(me.glob.GlobSync).once.args("dupakupa").in(seq)
    inquisitor.expect(me.anotherGlob.depGlobSync).once.args("dupakupa").in(seq)
    me.glob.GlobSync("dupakupa")
    me.anotherGlob.depGlobSync("dupakupa")

  it 'allows doubles through options', ->
    myGlob = GlobSync: -> return '/.ssh/id_rsa.priv'
    me = chamber("test/exampleUUT.js", replace:['glob': myGlob], replacer: inquisitor.mockify).whitebox()
    expect(glob.GlobSync('*')).to.be.not.equal('/.ssh/id_rsa.priv')
    expect(me.arrangeHeapDumps('dupakupa')).to.be.equal('/.ssh/id_rsa.priv')

describe 'chamber for MT', ->

  stimulation = (uut)->
    uut.arrangeHeapDumps('bleble')
    uut.anotherGlobCalledViaNextStageDep()
    uut.farCall()
    glob.GlobSync('*')

  commonExpects = (mock)->
    inquisitor.expect(mock['node_modules/glob/glob.js'].GlobSync).once.args('bleble')
    inquisitor.expect(mock['node_modules/glob/glob.js'].glob).once.args('bleble')
    inquisitor.expect(mock['node_modules/glob/glob.js'].GlobSync).once.args('jojo')
    inquisitor.expect(mock['node_modules/glob/glob.js'].GlobSync).once.args('dep.js')
    inquisitor.expect(mock['fakePackage/farDependancy.js'].caracole).once

  it 'replaces listed modules outside of my dir', ->
    seance = chamber('test/exampleUUT.js', replace:['glob', '../fakePackage/farDependancy'], replacer: inquisitor.mockify)
    me = seance.blackbox()
    mocks = seance.getTestDoubles()
    commonExpects(mocks)
    stimulation(me)

  it 'replaces automatically other implementation modules from my project (outside of my dir), but not the ones from the node_modules dir', ->
    seance = chamber('test/exampleUUT.js', replace:['glob', '../*'], replacer: inquisitor.mockify)
    me = seance.blackbox()
    mocks = seance.getTestDoubles()
    commonExpects(mocks)
    stimulation(me)

  it 'replaces automatically other implementation modules from my project (including my dir), but not the ones from the node_modules dir', ->
    seance = chamber('test/exampleUUT.js', replace:['glob', '*'], replacer: inquisitor.mockify)
    me = seance.blackbox()
    mocks = seance.getTestDoubles()
    inquisitor.expect(mocks['test/dep.js'].secondStageGlobSync).once
    inquisitor.expect(mocks['test/dep.js'].NoRefFunc).once
    inquisitor.expect(mocks['node_modules/glob/glob.js'].GlobSync).once
    inquisitor.expect(mocks['fakePackage/farDependancy.js'].caracole).once
    stimulation(me)

  it 'stubs (mocks shouldn\'t be called)', ->
    seance = chamber('test/exampleUUT.js', replace:['glob': {GlobSync: -> return 'jojojoa'}])
    me = seance.blackbox()
    expect(me.callGlobSync('łochocho')).to.be.equal('jojojoa')

  it 'mixes stubs and mocks', ->
    seance = chamber('test/exampleUUT.js', replace:['glob': {GlobSync: -> return 'jojojoa'}, '../*'], replacer: inquisitor.mockify)
    me = seance.blackbox()
    double = seance.getTestDoubles()
    inquisitor.expect(double['fakePackage/farDependancy.js'].caracole).once
    expect(me.callGlobSync('łochocho')).to.be.equal('jojojoa')
    stimulation(me)
