var express = require("express")
  , gzippo = require("gzippo")
  , oregano = require("./lib/oregano")
  , neo4j = require("neo4j")
  , request = require("request")
  , app = express()
  , neo4jLocal = "http://localhost:7474"
  , neo4jProd = process.env.NEO4J_URL
  , env = {db: undefined, request: request};

app.use(express.bodyParser());
app.use(express.methodOverride());
app.use(express.logger("dev"));
app.use(express.favicon());

app.configure("development", function(){
  app.use(express.errorHandler());
  app.use(express.static(__dirname + "/public"));
  env.db = new neo4j.GraphDatabase(neo4jLocal);
});

app.configure("production", function(){
  var fiveYears = 31557600000 * 5;
  app.use(gzippo.staticGzip(__dirname + "/public", {
    maxAge: fiveYears,
    clientMaxAge: fiveYears 
  }));
  env.db = new neo4j.GraphDatabase(neo4jProd);
});

app.post("/urls/:id/view", function(req, res){
  oregano.runReader(oregano.createUrlView(req.body.id, req.body.key), env).
    done(function(){res.send(201);}).
    fail(function(e){console.error(e); res.send(400);});
});

app.post("/urls/:id/pinch", function(req, res){
  oregano.runReader(oregano.createUrlPinch(req.body.id, req.body.key), env).
    done(function(){res.send(201);}).
    fail(function(e){console.error(e); res.send(400);});
});

app.post("/urls", function(req, res){
  oregano.runReader(oregano.createUrl(req.body.url, req.body.key), env).
    done(function(url){res.json(201, url);}).
    fail(function(e){console.error(e); res.send(400);});
});

app.get("/urls", function(req, res){
  oregano.runReader(oregano.indexUrls(req.param("key")), env).
    done(function(urls){res.json(200, urls);}).
    fail(function(e){console.error(e); res.send(400);});
});

app.get("/site.manifest", function(req, res, next){
  res.header("Content-Type", "text/cache-manifest");
  next();
});

app.get("/", function(req, res){
  res.sendfile(__dirname + "/public/index.html");
});

var nodePort = process.env.PORT || 5000
  , nodeEnv = process.env.NODE_ENV || "development";

app.listen(nodePort);

console.log("Express server listening on port " + nodePort + " in " + nodeEnv);
