expect = require("chai").expect
inquisitor = require "@nokia/inquisitor"
myIllusions = inquisitor.makeGlobalMock
deprivation = require("../")
chamber = deprivation.chamber
deprivation.stimulates(myIllusions)

describe "deprivation chamber", ->

  it "must expose my interior", ->
    seance = chamber("test/exampleUUT.js")
    me = seance.exposeInterior()
    expect(me.arrangeHeapDumps).be.ok
    me.glob.GlobSync("kupadupa")

  it "must provide illusions", ->
    seance = chamber("test/exampleUUT.js", mock:["glob"])
    me = seance.exposeInterior()

    inquisitor.expect(me.glob.GlobSync).once.args("kupadupa")
    me.glob.GlobSync("kupadupa")

  it "must provide relative illusions", ->
    seance = chamber("test/exampleUUT.js", mock:["./dep.js"])
    me = seance.exposeInterior()
    inquisitor.expect(me.anotherGlob.GlobSync).once.args("dupakupa")
    me.anotherGlob.GlobSync("dupakupa")
