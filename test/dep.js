var glob = require("glob");

function GlobSync() {
    console.log("dep: GlobSync");
}

function secondStageGlobSync() {
    glob.GlobSync("jojo");
    glob.glob('bleble')
}

module.exports.GlobSync = GlobSync;
module.exports.secondStageGlobSync = secondStageGlobSync;
