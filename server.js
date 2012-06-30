var express = require("express")
  , gzippo = require("gzippo")
  , app = express();

app.use(express.bodyParser());
app.use(express.methodOverride());
app.use(express.logger("dev"));
app.use(express.favicon());

app.configure("development", function(){
  app.use(express.errorHandler());
  app.use(express.static(__dirname + "/public"));
});

app.configure("production", function(){
  var fiveYears = 31557600000 * 5;
  app.use(gzippo.staticGzip(__dirname + "/public", {
    maxAge: fiveYears,
    clientMaxAge: fiveYears 
  }));
});

app.get("/", function(req, res){
  res.sendfile(__dirname + "/public/index.html");
});

var urls = [];
app.post("/urls", function(req, res){
  urls.push(req.body.url);
  res.send(201);
});

app.get("/urls", function(req, res){
  res.json(200, urls);
});

var port = process.env.PORT || 5000
  , env = process.env.NODE_ENV || "development";

app.listen(port);

console.log("Express server listening on port " + port + " in " + env);
