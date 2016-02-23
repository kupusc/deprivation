expect = require("chai").expect
inquisitor = require "@nokia/inquisitor"
sandbox = require("../")

describe "sandboxify", ->

  it "must return sandbox", ->
    sndbx = new sandbox("test/exampleUUT.js")
    uut = sndbx.giveSandbox()
    expect(uut.arrangeHeapDumps).be.ok
    uut.glob.GlobSync("kupadupa")

  it "must mock whole modules from node_modules", ->
    sndbx = new sandbox("test/exampleUUT.js", mock:["glob"])
    sndbx.setDoubleMaker(inquisitor.makeGlobalMock)
    uut = sndbx.giveSandbox()

    inquisitor.expect(uut.glob.GlobSync).once.args("kupadupa")
    uut.glob.GlobSync("kupadupa")

#  it "must mock modules from relative paths", ->
#    uut = sandboxify("test/exampleUUT.js", mock:["glob", "./dep.js"])
