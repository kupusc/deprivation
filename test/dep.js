var globen = require("glob");

function depGlobSync() {
    console.log("dep: GlobSync");
}

function secondStageGlobSync() {
    globen.GlobSync("jojo");
    globen.glob('bleble')
}

module.exports.depGlobSync = depGlobSync;
module.exports.secondStageGlobSync = secondStageGlobSync;
module.exports.NoRefFunc = function() {
    return globen.GlobSync('dep.js');
}
