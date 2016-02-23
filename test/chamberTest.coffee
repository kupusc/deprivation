expect = require("chai").expect
inquisitor = require "@nokia/inquisitor"
myIllusionMaker = inquisitor.makeGlobalMock
deprivation = require("../")

describe "chamber", ->

  it "must give the real experience", ->
    seance = deprivation("test/exampleUUT.js")
    uut = seance.giveImpression()
    expect(uut.arrangeHeapDumps).be.ok
    uut.glob.GlobSync("kupadupa")

  it "must mock whole modules from node_modules", ->
    seance = deprivation("test/exampleUUT.js", mock:["glob"], myIllusionMaker)
    uut = seance.giveImpression()

    inquisitor.expect(uut.glob.GlobSync).once.args("kupadupa")
    uut.glob.GlobSync("kupadupa")

  it "must mock modules from relative paths", ->
    seance = deprivation("test/exampleUUT.js", mock:["./dep.js"], myIllusionMaker)
    uut = seance.giveImpression()
    inquisitor.expect(uut.anotherGlob.GlobSync).once.args("dupakupa")
    uut.anotherGlob.GlobSync("dupakupa")
