expect = require("chai").expect
inquisitor = require "@nokia/inquisitor"
myIllusions = inquisitor.makeGlobalMock
deprivation = require("../")
chamber = deprivation.chamber
deprivation.accepts(myIllusions)

describe "deprivation chamber", ->

  it "must expose my interior", ->
    seance = chamber("test/exampleUUT.js")
    me = seance.exposeInterior()
    expect(me.arrangeHeapDumps).be.ok
    me.glob.GlobSync("kupadupa")

  it "must provide illusions", ->
    seance = chamber("test/exampleUUT.js", replace:["glob"])
    me = seance.exposeInterior()

    inquisitor.expect(me.glob.GlobSync).once.args("kupadupa")
    me.glob.GlobSync("kupadupa")

  it "must provide relative illusions", ->
    seance = chamber("test/exampleUUT.js", replace:["./dep.js"])
    me = seance.exposeInterior()
    inquisitor.expect(me.anotherGlob.GlobSync).once.args("dupakupa")
    me.anotherGlob.GlobSync("dupakupa")

  it "must not mix mocks with the same names from different modules", ->
    seance = chamber("test/exampleUUT.js", replace:["./dep.js", "glob"])
    me = seance.exposeInterior()
    inquisitor.expect(me.anotherGlob.GlobSync).once.args("dupakupa")
    me.anotherGlob.GlobSync("dupakupa")
