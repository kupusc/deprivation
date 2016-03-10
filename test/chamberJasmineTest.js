var deprivation = require("../");
var chamber = deprivation.chamber;

var myReplacer = function (obj) {
    newObj = new function () {
    };
    Object.keys(obj).forEach(function (item) {
        spyOn(obj, item);
        newObj[item] = obj.item;
    });
    return Object.keys(obj);
}

var seance, sut, spies;

describe('mocking with jasmine', function () {

    seance = chamber("test/exampleUUT.js", {replace: ['glob', '../*'], replacer: myReplacer});

    beforeEach(function () {
        sut = seance.blackbox();
        spies = seance.getTestDoubles();
    });

    it('works', function () {
        sut.arrangeHeapDumps('bleble');
        expect(spies['node_modules/glob/glob.js'].GlobSync).toHaveBeenCalled();
    });
});
