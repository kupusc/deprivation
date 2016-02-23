expect = require("chai").expect
inquisitor = require "@nokia/inquisitor"
sandbox = require("../")

describe "sandboxify", ->

  it "must return sandbox", ->
    sndbx = new sandbox.Sandbox("test/exampleUUT.js")
    uut = sndbx.giveSandbox()
    expect(uut.arrangeHeapDumps).be.ok
    uut.glob.GlobSync("kupadupa")

  it "must mock whole modules", ->
#    uut = sandboxify("test/exampleUUT.js", mock:["glob", "./dep.js"])
    sndbx = new sandbox.Sandbox("test/exampleUUT.js", mock:["glob"])
    sndbx.setDoubleMaker(inquisitor.makeGlobalMock)
    sandbox.setMocker(inquisitor.makeGlobalMock)
    uut = sndbx.giveSandbox()

    inquisitor.expect(uut.glob.GlobSync).once.args("kupadupa")
    uut.glob.GlobSync("kupadupa")

#  it "must take relative path", ->
#    sandboxify "./exampleUUT.js"
