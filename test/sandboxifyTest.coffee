expect = require("chai").expect
sandboxify = require "../lib/sandboxify"
inquisitor = require "@nokia/inquisitor"

describe "sandboxify", ->
  it "must return sandbox", ->
    uut = sandboxify "test/exampleUUT.js"
    expect(uut.arrangeHeapDumps).be.ok
    uut.glob.GlobSync("kupadupa")

  it "must mock whole modules", ->
    uut = sandboxify "test/exampleUUT.js", {mock: ["glob"]}
    snapshotCfg = {
      snapshotFiles: {},
      btsLogBaseDir: "griffin"
    };

    inquisitor.expect(uut.glob.GlobSync).once.args("kupadupa")
    uut.glob.GlobSync("kupadupa")

  it "must take relative path", ->
    sandboxify "./exampleUUT.js"
