var dep = require('../test/dep.js')

var caracole = function() {
    return 'oh, yes!';
}

var callAgainParent = function(){
    dep.depGlobSync();
}

module.exports.caracole = caracole;
module.exports.callAgainParent = callAgainParent;
