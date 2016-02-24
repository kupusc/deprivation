expect = require("chai").expect

deprivation = require("../")
chamber = deprivation.chamber

describe "deprivation chamber", ->

  it "must expose my interior", ->
    seance = chamber("test/exampleUUT.js")
    me = seance.exposeInterior()
    expect(me.arrangeHeapDumps).be.ok
    me.glob.GlobSync("kupadupa")
