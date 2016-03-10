expect = require("chai").expect
glob = require('glob')

deprivation = require "../"
chamber = deprivation.chamber

describe "deprivation chamber for UT", ->

  it "exposes my interior", ->
    me = chamber("test/exampleUUT.js").whitebox()
    expect(me.arrangeHeapDumps).be.ok
    me.arrangeHeapDumps("kupadupa")
    me.module.exports.NoRefFunc()

describe 'chamber for MT', ->

  it 'stubs (mocks shouldn\'t be called)', ->
    seance = chamber('test/exampleUUT.js', replace:['glob': {GlobSync: -> return 'jojojoa'}])
    me = seance.blackbox()
    expect(me.callGlobSync('łochocho')).to.be.equal('jojojoa')
