var expect = require("chai").expect
  , sinon = require("sinon")
  , oregano = require("../../lib/oregano.js");

var db = {
  query: function(_, _, f){return f();},
  createNode: function(data){return node(data);},
  getNodeById: function(_, f){return f();},
};

var request = function(url, f){
  // f takes (error, response, body)
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
    this.env = {db: db, request: request};
  });
  afterEach(function(){
    if (this.env.db.query.restore)
      this.env.db.query.restore();
    if (this.env.db.createNode.restore)
      this.env.db.createNode.restore();
    if (this.env.db.getNodeById.restore)
      this.env.db.getNodeById.restore();
  });

  describe("#createUrl", function(){
    beforeEach(function(){
      this.url = "http://url.com";
      this.key = "key";
    });
    describe("when the url is created successfully", function(){
      beforeEach(function(){
        var that = this;
        this.stubQuery = sinon.stub(this.env.db, "query", function(_, _, f){
          return f(undefined, [{a: node({id: that.id})}]);
        });
      });
      describe("when the url's page title is fetched successfully", function(){
        beforeEach(function(){
          this.error = false;
          this.response = {statusCode: 200};
        });
        describe("when there is a single title tag", function(){
          beforeEach(function(){
            this.title = "The URL";
            this.body = "<html><head><title>" + this.title + "</title></head></html>";
          });
          beforeEach(function(){
            var that = this;
            this.stubRequest = sinon.stub(this.env, "request", function(_, f){
              return f(that.error, that.response, that.body);
            });
          });
          beforeEach(function(){
            this.res = this.subject.runReader(
              this.subject.createUrl(this.url, this.key),
              this.env
            );
          });
          it("should result in an object with a node ID", k(function(res){
            expect(res.id).to.not.be.empty;
          }));
          it("should result in an object with a node URL", k(function(res){
            expect(res.url).to.equal(this.url);
          }));
          it("should result in an object with a node title", k(function(res){
            expect(res.title).to.equal(this.title);
          }));
        });
        describe("when there is no title tag", function(){
          beforeEach(function(){
            this.title = "";
            this.body = "<html><head></head></html>";
          });
          beforeEach(function(){
            var that = this;
            this.stubRequest = sinon.stub(this.env, "request", function(_, f){
              return f(that.error, that.response, that.body);
            });
          });
          beforeEach(function(){
            this.res = this.subject.runReader(
              this.subject.createUrl(this.url, this.key),
              this.env
            );
          });
          it("should result in an object with a node ID", k(function(res){
            expect(res.id).to.not.be.empty;
          }));
          it("should result in an object with a node URL", k(function(res){
            expect(res.url).to.equal(this.url);
          }));
          it("should result in an object with a node title", k(function(res){
            expect(res.title).to.equal(this.title);
          }));
        });
        describe("when there are multiple title tags", function(){
          beforeEach(function(){
            this.titles = ["One", "Two", "", "Three"];
            this.body = "<html><head>" + this.titles.map(function(a){
                return "<title>" + a + "</title>";
            }) + "</head></html>";
          });
          beforeEach(function(){
            var that = this;
            this.stubRequest = sinon.stub(this.env, "request", function(_, f){
              return f(that.error, that.response, that.body);
            });
          });
          beforeEach(function(){
            this.res = this.subject.runReader(
              this.subject.createUrl(this.url, this.key),
              this.env
            );
          });
          it("should result in an object with a node ID", k(function(res){
            expect(res.id).to.not.be.empty;
          }));
          it("should result in an object with a node URL", k(function(res){
            expect(res.url).to.equal(this.url);
          }));
          it("should result in an object with a node title", k(function(res){
            expect(res.title).to.equal(this.titles.join(""));
          }));
        });
      });
    });

    describe("when the url is not created successfully", function(){
      describe("when the user is not found", function(){
        beforeEach(function(){
          this.stubQuery = sinon.stub(this.env.db, "query", function(_, _, f){
            return f(undefined, []);
          });
        });
        beforeEach(function(){
          this.res = this.subject.runReader(
            this.subject.createUrl(this.url, this.key),
            this.env
          );
        });
        it("should result in a rejected deferred", function(){
          expect(this.res.state()).to.equal("rejected");
        });
      });
      describe("when the node fails to be saved", function(){
        beforeEach(function(){
          var that = this;
          this.node = node();
          sinon.stub(this.node, "save", function(f){
            return f("failed to save");
          });
          sinon.stub(this.env.db, "query", function(_, _, f){
            return f(undefined, [{a: node()}]);
          });
          sinon.stub(this.env.db, "createNode", function(_){
            return that.node;
          }); 
        });
        beforeEach(function(){
          this.error = false;
          this.response = {statusCode: 200};
          this.body = "";
        });
        beforeEach(function(){
          var that = this;
          this.stubRequest = sinon.stub(this.env, "request", function(_, f){
            return f(that.error, that.response, that.body);
          });
        });
        beforeEach(function(){
          this.res = this.subject.runReader(
            this.subject.createUrl(this.url, this.key),
            this.env
          );
        });
        it("should result in a rejected deferred", function(){
          expect(this.res.state()).to.equal("rejected");
        });
      });
      describe("when the rel fails to be created", function(){
        beforeEach(function(){
          var that = this;
          this.node = node();
          sinon.stub(this.node, "createRelationshipTo", function(_, _, _, f){
            return f("failed to create rel");
          });
          sinon.stub(this.env.db, "query", function(_, _, f){
            return f(undefined, [{a: that.node}]);
          });
        });
        beforeEach(function(){
          this.error = false;
          this.response = {statusCode: 200};
          this.body = "";
        });
        beforeEach(function(){
          var that = this;
          this.stubRequest = sinon.stub(this.env, "request", function(_, f){
            return f(that.error, that.response, that.body);
          });
        });
        beforeEach(function(){
          this.res = this.subject.runReader(
            this.subject.createUrl(this.url, this.key),
            this.env
          );
        });
        it("should result in a rejected deferred", function(){
          expect(this.res.state()).to.equal("rejected");
        });
      });
    });
    describe("when the title fails to be fetched", function(){
      beforeEach(function(){
        var that = this;
        this.stubQuery = sinon.stub(this.env.db, "query", function(_, _, f){
          return f(undefined, [{a: node({id: that.id})}]);
        });
      });
      beforeEach(function(){
        this.error = true;
        this.response = {statusCode: 404};
        this.body = undefined;
      });
      beforeEach(function(){
        var that = this;
        this.stubRequest = sinon.stub(this.env, "request", function(_, f){
          return f(that.error, that.response, that.body);
        });
      });
      beforeEach(function(){
        this.res = this.subject.runReader(
          this.subject.createUrl(this.url, this.key),
          this.env
        );
      });
      it("should result in a rejected deferred", function(){
        expect(this.res.state()).to.equal("rejected");
      });
    });
  });

  describe("#indexUrls", function(){
    describe("when the urls are fetched successfully", function(){
      beforeEach(function(){
        this.nodes = [
          node({id: 1, url: "a", title: "b", relTypes: ["adds","pinches"]}),
          node({id: 2, url: "a", title: "", relTypes: ["adds","views"]}),
          node({id: 3, url: "a", title: "c", relTypes: ["adds","views","pinches"]}),
        ];
      });
      beforeEach(function(){
        var that = this;
        sinon.stub(this.env.db, "query", function(query, _, f){
          return f(undefined, that.nodes.map(function(a){
            return {
              id: a.id,
              url: a.data.url,
              title: a.data.title,
              relTypes: a.data.relTypes
            };
          }));
        });
      });
      beforeEach(function(){
        this.res = this.subject.runReader(
          this.subject.indexUrls(this.key),
          this.env
        );
      });
      it("should return the adds rels", k(function(res){
        expect(res.length).to.equal(this.nodes.length);
      }));
      it("should have an id", k(function(res){
        res.forEach(function(a, i){
          expect(res[i].id).to.equal(this.nodes[i].id);
        }, this);
      }));
      it("should have a url", k(function(res){
        res.forEach(function(a, i){
          expect(res[i].url).to.equal(this.nodes[i].data.url);
        }, this);
      }));
      it("should have a title", k(function(res){
        res.forEach(function(a, i){
          expect(res[i].title).to.equal(this.nodes[i].data.title);
        }, this);
      }));
      it("should have rel types", k(function(res){
        expect(res[0].relTypes).to.eql(["adds","pinches"]);
        expect(res[1].relTypes).to.eql(["adds","views"]);
        expect(res[2].relTypes).to.eql(["adds","views", "pinches"]);
      }));
    });

    describe("when the url are not fetched successfully", function(){
      beforeEach(function(){
        sinon.stub(this.env.db, "query", function(query, _, f){
          return f("failed");
        });
        this.res = this.subject.runReader(
          this.subject.indexUrls(this.key),
          this.env
        );
      });
      it("should be a rejected deferred", function(){
          expect(this.res.state()).to.equal("rejected");
      });
    });
  });

  describe("#createUrlView", function(){
    beforeEach(function(){
      var that = this;
      this.id = "a";
      this.user = node({id: "1"});
      this.node = node({id: this.id});
      sinon.stub(this.env.db, "query", function(query, _, f){
        return query.match(/r:views/) ?
          f(undefined, that.views) : f(undefined, [{a: that.user}]);
      });
      sinon.stub(this.env.db, "getNodeById", function(_, f){
        return f(undefined, that.node);
      });
    });
    describe("when the views rel is created successfully", function(){
      beforeEach(function(){
        this.views = [];
        sinon.stub(this.user, "createRelationshipTo", function(_, _, _, f){
          return f();
        });
        this.res = this.subject.runReader(
          this.subject.createUrlView(this.id, this.key),
          this.env
        );
      });
      it("should be a resolved deferred", function(){
        expect(this.res.state()).to.equal("resolved");
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
        this.res = this.subject.runReader(
          this.subject.createUrlView(this.id, this.key),
          this.env
        );
      });
      it("should be a resolved deferred", function(){
        expect(this.res.state()).to.equal("resolved");
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
        this.res = this.subject.runReader(
          this.subject.createUrlView(this.id, this.key),
          this.env
        );
      });
      it("should be a rejected deferred", function(){
        expect(this.res.state()).to.equal("rejected");
      });
    });
  });

  describe("#createUrlPinch", function(){
    beforeEach(function(){
      var that = this;
      this.id = "a";
      this.user = node({id: "1"});
      this.node = node({id: this.id});
      sinon.stub(this.env.db, "query", function(query, _, f){
        return query.match(/r:pinches/) ?
          f(undefined, that.views) : f(undefined, [{a: that.user}]);
      });
      sinon.stub(this.env.db, "getNodeById", function(_, f){
        return f(undefined, that.node);
      });
    });
    describe("when the pinches rel is created successfully", function(){
      beforeEach(function(){
        this.views = [];
        sinon.stub(this.user, "createRelationshipTo", function(_, _, _, f){
          return f();
        });
        this.res = this.subject.runReader(
          this.subject.createUrlPinch(this.id, this.key),
          this.env
        );
      });
      it("should be a resolved deferred", function(){
        expect(this.res.state()).to.equal("resolved");
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
        this.res = this.subject.runReader(
          this.subject.createUrlPinch(this.id, this.key),
          this.env
        );
      });
      it("should be a resolved deferred", function(){
        expect(this.res.state()).to.equal("resolved");
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
        this.res = this.subject.runReader(
          this.subject.createUrlPinch(this.id, this.key),
          this.env
        );
      });
      it("should be a rejected deferred", function(){
        expect(this.res.state()).to.equal("rejected");
      });
    });
  });
});
