expect = require("chai").expect

deprivation = require "../"
chamber = deprivation.chamber

describe "deprivation chamber", ->

  it "exposes my interior", ->
    seance = chamber("test/exampleUUT.js")
    me = seance.exposeInterior()
    expect(me.arrangeHeapDumps).be.ok
    me.glob.GlobSync("kupadupa")

  it "replaces functions in UUT", ->
    seance = chamber("test/exampleUUT.js")
    me = seance.exposeInterior()
    me.glob = => 55
    expect(me.glob("kupadupa")).be.equal(55)


  it 'allows doubles through options', ->
    myGlob = GlobSync: -> return '/.ssh/id_rsa.priv'
    seance = chamber("test/exampleUUT.js", replace:["glob": myGlob])
    me = seance.exposeInterior()
    expect(me.glob.GlobSync("dupakupa")).to.be.equal('/.ssh/id_rsa.priv')