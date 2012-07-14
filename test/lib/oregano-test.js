var expect = require("chai").expect
  , sinon = require("sinon")
  , oregano = require("../../lib/oregano.js");

var node  = {
  createRelationshipTo: function(_, _, _, f){
    return f();
  }
};

var db = {
  query: function(_, _, f){return f();},
  createNode: function(data){return node(data);},
  getNodeById: function(_, f){return f();},
};

var node = function(data){
  return {
    id: data && data.id || "id",
    data: data,
    type: data && data.type || "type",
    save: function(f){return f();},
    createRelationshipTo: function(_, _, _, f){return f();},
  };
};

var k = function(f){
  return function(k){
    var that = this;
    this.res.done(function(res){
      f.apply(that, [res]);
      k();
    });
  };
};

describe("Oregano", function(){
  beforeEach(function(){
    this.subject = oregano;
    this.db = db;
  });
  afterEach(function(){
    if (this.db.query.restore)
      this.db.query.restore();
    if (this.db.createNode.restore)
      this.db.createNode.restore();
    if (this.db.getNodeById.restore)
      this.db.getNodeById.restore();
  });

  describe("#createUrl", function(){
    beforeEach(function(){
      this.url = "http://url.com";
      this.key = "key";
    });
    describe("when the url is created successfully", function(){
      beforeEach(function(){
        var that = this;
        this.stubQuery = sinon.stub(this.db, "query", function(_, _, f){
          return f(undefined, [{a: node({id: that.id})}]);
        });
      });
      beforeEach(function(){
        this.res = this.subject.runDB(
          this.subject.createUrl(this.url, this.key),
          this.db
        );
      });
      it("should result in an object with a node ID", k(function(res){
        expect(res.id).to.not.be.empty;
      }));
      it("should result in an object with a node URL", k(function(res){
        expect(res.url).to.equal(this.url);
      }));
    });

    describe("when the url is not created successfully", function(){
      describe("when the user is not found", function(){
        beforeEach(function(){
          this.stubQuery = sinon.stub(this.db, "query", function(_, _, f){
            return f(undefined, []);
          });
        });
        beforeEach(function(){
          this.res = this.subject.runDB(
            this.subject.createUrl(this.url, this.key),
            this.db
          );
        });
        it("should result in a rejected deferred", function(){
          expect(this.res.isRejected()).to.be.true
        });
      });
      describe("when the node fails to be saved", function(){
        beforeEach(function(){
          var that = this;
          this.node = node();
          sinon.stub(this.node, "save", function(f){
            return f("failed to save");
          });
          sinon.stub(this.db, "query", function(_, _, f){
            return f(undefined, [{a: node()}]);
          });
          sinon.stub(this.db, "createNode", function(_){
            return that.node;
          }); 
        });
        beforeEach(function(){
          this.res = this.subject.runDB(
            this.subject.createUrl(this.url, this.key),
            this.db
          );
        });
        it("should result in a rejected deferred", function(){
          expect(this.res.isRejected()).to.be.true
        });
      });
      describe("when the rel fails to be created", function(){
        beforeEach(function(){
          var that = this;
          this.node = node();
          sinon.stub(this.node, "createRelationshipTo", function(_, _, _, f){
            return f("failed to create rel");
          });
          sinon.stub(this.db, "query", function(_, _, f){
            return f(undefined, [{a: that.node}]);
          });
        });
        beforeEach(function(){
          this.res = this.subject.runDB(
            this.subject.createUrl(this.url, this.key),
            this.db
          );
        });
        it("should result in a rejected deferred", function(){
          expect(this.res.isRejected()).to.be.true
        });
      });
    });
  });

  describe("#indexUrls", function(){
    describe("when the urls are fetched successfully", function(){
      beforeEach(function(){
        this.adds = [
          node({id: 1, url: "a", type: "adds"}),
          node({id: 2, url: "a", type: "adds"}),
          node({id: 3, url: "a", type: "adds"}),
        ];
        this.views = [
          [],
          [node({id: 4, type: "views"})],
          [node({id: 5, type: "views"})],
        ];
        this.pinches = [
          [node({id: 6, type: "pinches"})],
          [],
          [node({id: 7, type: "pinches"})],
        ];
      });
      beforeEach(function(){
        var that = this;
        sinon.stub(this.db, "query", function(query, _, f){
          if (query.match(/r:adds/)) {
            return f(undefined, that.adds.map(function(a){
              return {b: a};
            }));
          }
          else if (query.match(/r:views/)) {
            return f(undefined, that.views.shift().map(function(a){
              return {r: a};
            }));
          }
          else if (query.match(/r:pinches/)) {
            return f(undefined, that.pinches.shift().map(function(a){
              return {r: a};
            }));
          }
        });
      });
      beforeEach(function(){
        this.res = this.subject.runDB(
          this.subject.indexUrls(this.key),
          this.db
        );
      });
      it("should return the adds rels", k(function(res){
        expect(res.length).to.equal(this.adds.length);
      }));
      it("should have an id", k(function(res){
        res.forEach(function(a, i){
          expect(res[i].id).to.equal(this.adds[i].id);
        }, this);
      }));
      it("should have a url", k(function(res){
        res.forEach(function(a, i){
          expect(res[i].url).to.equal(this.adds[i].data.url);
        }, this);
      }));
      it("should have rel types", k(function(res){
        expect(res[0].relTypes).to.eql(["pinches"]);
        expect(res[1].relTypes).to.eql(["views"]);
        expect(res[2].relTypes).to.eql(["views", "pinches"]);
      }));
    });

    describe("when the url are not fetched successfully", function(){
      beforeEach(function(){
        sinon.stub(this.db, "query", function(query, _, f){
          return f("failed");
        });
        this.res = this.subject.runDB(
          this.subject.indexUrls(this.key),
          this.db
        );
      });
      it("should be a rejected deferred", function(){
        expect(this.res.isRejected()).to.be.true
      });
    });
  });

  describe("#createUrlView", function(){
    beforeEach(function(){
      var that = this;
      this.id = "a";
      this.user = node({id: "1"});
      this.node = node({id: this.id});
      sinon.stub(this.db, "query", function(query, _, f){
        return query.match(/r:views/) ?
          f(undefined, that.views) : f(undefined, [{a: that.user}]);
      });
      sinon.stub(this.db, "getNodeById", function(_, f){
        return f(undefined, that.node);
      });
    });
    describe("when the views rel is created successfully", function(){
      beforeEach(function(){
        this.views = [];
        sinon.stub(this.user, "createRelationshipTo", function(_, _, _, f){
          return f();
        });
        this.res = this.subject.runDB(
          this.subject.createUrlView(this.id, this.key),
          this.db
        );
      });
      it("should be a resolved deferred", function(){
        expect(this.res.isResolved()).to.be.true;
      });
      it("should create a views rel", function(){
        expect(this.user.createRelationshipTo.calledOnce).to.be.true;
      });
    });
    describe("when the views rel already exists", function(){
      beforeEach(function(){
        this.views = [{r: node({id: 2, type: "views"})}],
        sinon.stub(this.user, "createRelationshipTo", function(_, _, _, f){
          return f("should not reach this point");
        });
        this.res = this.subject.runDB(
          this.subject.createUrlView(this.id, this.key),
          this.db
        );
      });
      it("should be a resolved deferred", function(){
        expect(this.res.isResolved()).to.be.true;
      });
      it("should not create a views rel", function(){
        expect(this.user.createRelationshipTo.notCalled).to.be.true;
      });
    });
    describe("when the views rel fails", function(){
      beforeEach(function(){
        this.views = [];
        sinon.stub(this.user, "createRelationshipTo", function(_, _, _, f){
          return f("fail");
        });
        this.res = this.subject.runDB(
          this.subject.createUrlView(this.id, this.key),
          this.db
        );
      });
      it("should be a rejected deferred", function(){
        expect(this.res.isRejected()).to.be.true;
      });
    });
  });

  describe("#createUrlPinch", function(){
    beforeEach(function(){
      var that = this;
      this.id = "a";
      this.user = node({id: "1"});
      this.node = node({id: this.id});
      sinon.stub(this.db, "query", function(query, _, f){
        return query.match(/r:pinches/) ?
          f(undefined, that.views) : f(undefined, [{a: that.user}]);
      });
      sinon.stub(this.db, "getNodeById", function(_, f){
        return f(undefined, that.node);
      });
    });
    describe("when the pinches rel is created successfully", function(){
      beforeEach(function(){
        this.views = [];
        sinon.stub(this.user, "createRelationshipTo", function(_, _, _, f){
          return f();
        });
        this.res = this.subject.runDB(
          this.subject.createUrlPinch(this.id, this.key),
          this.db
        );
      });
      it("should be a resolved deferred", function(){
        expect(this.res.isResolved()).to.be.true;
      });
      it("should create a pinches rel", function(){
        expect(this.user.createRelationshipTo.calledOnce).to.be.true;
      });
    });
    describe("when the pinches rel already exists", function(){
      beforeEach(function(){
        this.views = [{r: node({id: 2, type: "views"})}],
        sinon.stub(this.user, "createRelationshipTo", function(_, _, _, f){
          return f("should not reach this point");
        });
        this.res = this.subject.runDB(
          this.subject.createUrlPinch(this.id, this.key),
          this.db
        );
      });
      it("should be a resolved deferred", function(){
        expect(this.res.isResolved()).to.be.true;
      });
      it("should not create a pinches rel", function(){
        expect(this.user.createRelationshipTo.notCalled).to.be.true;
      });
    });
    describe("when the pinches rel fails", function(){
      beforeEach(function(){
        this.views = [];
        sinon.stub(this.user, "createRelationshipTo", function(_, _, _, f){
          return f("fail");
        });
        this.res = this.subject.runDB(
          this.subject.createUrlPinch(this.id, this.key),
          this.db
        );
      });
      it("should be a rejected deferred", function(){
        expect(this.res.isRejected()).to.be.true;
      });
    });
  });
});
