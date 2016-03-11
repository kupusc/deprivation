var expect = require("chai").expect;
var glob = require('glob');

var deprivation = require("../");
var chamber = deprivation.chamber;

var seance, sut;

describe('stubbing', function() {

    var myGlob = {
        GlobSync: function() {
            return 'kupadupa';
        }
    };

    beforeEach(function () {
        seance = chamber("test/exampleUUT.js", {replace: [{'glob': myGlob}]});
        sut = seance.blackbox();
    });

    it('yes', function(){
        var actual = sut.callGlobSync('ojojoj');
        var expected = 'kupadupa';

        expect(actual).to.be.equal(expected);
    });
});


