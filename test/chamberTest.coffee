expect = require("chai").expect
inquisitor = require "@nokia/inquisitor"
myIllusionMaker = inquisitor.makeGlobalMock
deprivation = require("../")

describe "deprivating chamber", ->

  it "must expose my interior", ->
    seance = deprivation("test/exampleUUT.js")
    uut = seance.exposeInterior()
    expect(uut.arrangeHeapDumps).be.ok
    uut.glob.GlobSync("kupadupa")

  it "must provide illusions", ->
    seance = deprivation("test/exampleUUT.js", mock:["glob"], myIllusionMaker)
    uut = seance.exposeInterior()

    inquisitor.expect(uut.glob.GlobSync).once.args("kupadupa")
    uut.glob.GlobSync("kupadupa")

  it "must provide relative illusions", ->
    seance = deprivation("test/exampleUUT.js", mock:["./dep.js"], myIllusionMaker)
    uut = seance.exposeInterior()
    inquisitor.expect(uut.anotherGlob.GlobSync).once.args("dupakupa")
    uut.anotherGlob.GlobSync("dupakupa")
