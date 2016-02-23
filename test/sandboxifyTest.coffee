expect = require("chai").expect
inquisitor = require "@nokia/inquisitor"
sandman = require("../")

describe "sandboxify", ->

  it "must return sandbox", ->
    s = sandman("test/exampleUUT.js")
    uut = s.giveSandbox()
    expect(uut.arrangeHeapDumps).be.ok
    uut.glob.GlobSync("kupadupa")

  it "must mock whole modules from node_modules", ->
    s = sandman("test/exampleUUT.js", mock:["glob"])
    s.setDoubleMaker(inquisitor.makeGlobalMock)
    uut = s.giveSandbox()

    inquisitor.expect(uut.glob.GlobSync).once.args("kupadupa")
    uut.glob.GlobSync("kupadupa")

#  it "must mock modules from relative paths", ->
#    uut = sandboxify("test/exampleUUT.js", mock:["glob", "./dep.js"])
