expect = require("chai").expect

deprivation = require "../"
chamber = deprivation.chamber

describe "deprivation chamber", ->

  it "must expose my interior", ->
    seance = chamber("test/exampleUUT.js")
    me = seance.exposeInterior()
    expect(me.arrangeHeapDumps).be.ok
    me.glob.GlobSync("kupadupa")

  it "must allow replacing functions in UUT", ->
    seance = chamber("test/exampleUUT.js")
    me = seance.exposeInterior()
    me.glob = => 55
    expect(me.glob("kupadupa")).be.equal(55)
