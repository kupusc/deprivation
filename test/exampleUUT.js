var glob = require("glob");
var anotherGlob = require("./dep.js");
//require('missing module. I dont want this to crash.');

//console.log(anotherGlob);

var arrangeHeapDumps = function(a, b) {
    glob.GlobSync(a)
};

var returnCfgWithHeapsnapshotExtension = function(snapshotCfg) {

};

var anotherGlobCalledViaNextStageDep = function(a) {
    anotherGlob.secondStageGlobSync(a);
};

module.exports.arrangeHeapDumps = arrangeHeapDumps;
module.exports.returnCfgWithHeapsnapshotExtension = returnCfgWithHeapsnapshotExtension;
module.exports.anotherGlobCalledViaNextStageDep = anotherGlobCalledViaNextStageDep;
