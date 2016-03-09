var globen = require("glob");
var farDep = require('../fakePackage/farDependancy');

function depGlobSync() {
}

function secondStageGlobSync() {
    globen.GlobSync("jojo");
    globen.glob('bleble')
}

function thirdStageDep() {
    farDep.callAgainParent();
}

module.exports.depGlobSync = depGlobSync;
module.exports.secondStageGlobSync = secondStageGlobSync;
module.exports.NoRefFunc = function() {
    return globen.GlobSync('dep.js');
}
module.exports.thirdStageDep = thirdStageDep;
