var glob = require('glob');
var anotherGlob = require('./dep.js');
var farDep = require('../fakePackage/farDependancy');
var cl = console.log.bind(this, 'exampleUUT ---> ');

var arrangeHeapDumps = function(a) {
    return glob.GlobSync(a);
}

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

module.exports = {
    returnCfgWithHeapsnapshotExtension: returnCfgWithHeapsnapshotExtension,
    anotherGlobCalledViaNextStageDep: anotherGlobCalledViaNextStageDep,
    farCall: farCall,
    NoRefFunc: function() {
        return glob.GlobSync('jajaja');
    },
    fourthStageDep: function() {
        anotherGlob.thirdStageDep();
    },
    callGlobSync: function(a){
        //cl(glob);
        return glob.GlobSync(a);
    },
    depInitialized: anotherGlob.initializationCodeExecuted,
    arrangeHeapDumps: function(a) {
        return glob.GlobSync(a);
    }
};
