var glob = require('glob');
var anotherGlob = require('./dep.js');
var farDep = require('../fakePackage/farDependancy');
var cl = console.log.bind(this, 'exampleUUT ---> ');

//console.log(anotherGlob);

var arrangeHeapDumps = function(a) {
    return glob.GlobSync(a);
};

var returnCfgWithHeapsnapshotExtension = function(snapshotCfg) {

};

var anotherGlobCalledViaNextStageDep = function(a) {
    anotherGlob.secondStageGlobSync(a);
    anotherGlob.NoRefFunc();
};

var farCall = function() {
    farDep.caracole();
}

module.exports.arrangeHeapDumps = function(a) {
    return glob.GlobSync(a);
};
module.exports.returnCfgWithHeapsnapshotExtension = returnCfgWithHeapsnapshotExtension;
module.exports.anotherGlobCalledViaNextStageDep = anotherGlobCalledViaNextStageDep;
module.exports.farCall = farCall;
module.exports.NoRefFunc = function() {
    return glob.GlobSync('jajaja');
}

module.exports.fourthStageDep = function() {
    anotherGlob.thirdStageDep();
}

module.exports.callGlobSync = function(a){
    //cl(glob);
    return glob.GlobSync(a);
}
