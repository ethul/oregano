var crypto = require("crypto");
var deferred = require("JQDeferred");
var underscore = require("underscore");
var htmlparser = require("htmlparser");
var Reader = function(a_0) {
    if(!(this instanceof Reader)) {
        return new Reader(a_0);
    }
    this._0 = a_0;
};
var DB = function(a_0) {
    if(!(this instanceof DB)) {
        return new DB(a_0);
    }
    this._0 = a_0;
};
var Request = function(a_0) {
    if(!(this instanceof Request)) {
        return new Request(a_0);
    }
    this._0 = a_0;
};
var unit = {
    
};
var readerMonad = {
    "return": function(a) {
        return function(c) {
            return Reader(a);
        };
    },
    "bind": function(ma, f) {
        return function(c) {
            return (function() {
                if(ma instanceof Reader) {
                    var a = ma._0;
                    return f(a)(c);
                }
            })();
        };
    }
};
var runReader = function(ma, c) {
    var res = ma(c);
    return (function() {
        if(res instanceof Reader) {
            var a = res._0;
            return a;
        }
    })();
};
var deferredMonad = {
    "return": function(a) {
        return deferred.when(a);
    },
    "bind": function(ma, f) {
        var defer = deferred();
        ma.done(function(a) {
            var mb = f(a);
            mb.done(defer.resolve);
            return mb.fail(defer.reject);
        });
        ma.fail(defer.reject);
        return defer.promise();
    }
};
var readerDeferredMonad = {
    "return": function(a) {
        return readerMonad.return(deferredMonad.return(a));
    },
    "bind": function(m, f) {
        return function(c) {
            var x = m(c);
            return Reader(((function() {
                if(x instanceof Reader) {
                    var ma = x._0;
                    return ((function(){
                var __monad__ = deferredMonad;
                
                return __monad__.bind(ma, function(a) {
                    var y = f(a)(c)
                    return (function() {
                        if(y instanceof Reader) {
                            var mb = y._0;
                            return mb;
                        }
                    })()
                });
            })());
                }
            })()));
        };
    }
};
var liftReader = function(f) {
    return function(env) {
        return Reader(f(env));
    };
};
var liftDeferred = function(f) {
    var defer = deferred();
    f(defer);
    return defer.promise();
};
var liftReaderDeferred = function(f) {
    return liftReader(function(env) {
        return liftDeferred(function(defer) {
            return f(env, defer);
        });
    });
};
var liftDbOp = function(op) {
    return liftReaderDeferred(function(env, defer) {
        return op(env.db)(function(error, res) {
            return (function() {
                if(error) {
                    return defer.reject(error);
                } else {
                    return defer.resolve(res);
                }
            })();
        });
    });
};
var createRel = function(rel) {
    return function(from, to) {
        return liftDbOp(function(_) {
            return function(handler) {
                return from.createRelationshipTo(to, rel, {
                    
                }, handler);
            };
        });
    };
};
var getRel = function(rel) {
    return function(key, node) {
        var query = "START a=node:users(key={key}),b=node({id}) MATCH a-[r:" + rel + "]->b RETURN r";
        return (function(){
            var __monad__ = readerDeferredMonad;
            
            return __monad__.bind(liftDbOp(function(db) {
                return function(handler) {
                    return db.query(query, {
                        "key": key,
                        "id": node.id
                    }, handler);
                };
            }), function(res) {
                
                return __monad__.return(res.map(function(a) {
                    return a.r;
                }));
            });
        })();
    };
};
var getAllRel = function(key) {
    return ((function(){
        var __monad__ = readerDeferredMonad;
        var query = "START a=node:users(key={key}) MATCH a-[r:adds|views|pinches]->b RETURN id(b) AS id, b.url AS url, b.title? AS title, collect(type(r)) AS relTypes ORDER BY id(b)"
        return __monad__.bind(liftDbOp(function(db) {
            return function(handler) {
                return db.query(query, {
                    "key": key
                }, handler);
            };
        }), function(res) {
            
            return __monad__.return(res);
        });
    })());
};
var getUser = function(key) {
    return liftReaderDeferred(function(env, defer) {
        var query = "START a=node:users(key={key}) RETURN a";
        return env.db.query(query, {
            "key": key
        }, function(error, res) {
            return (function() {
                if(error || res.length == 0) {
                    return defer.reject(error);
                } else {
                    return defer.resolve(res.shift().a);
                }
            })();
        });
    });
};
var getNode = function(id) {
    return liftDbOp(function(db) {
        return function(handler) {
            return db.getNodeById(id, handler);
        };
    });
};
var saveNode = function(node) {
    return liftDbOp(function(_) {
        return function(handler) {
            return node.save(handler);
        };
    });
};
var fetchHtml = function(url) {
    return liftReaderDeferred(function(env, defer) {
        return env.request(url, function(error, res, body) {
            return (function() {
                if(! error && res.statusCode == 200) {
                    return defer.resolve(body);
                } else {
                    return defer.reject(error);
                }
            })();
        });
    });
};
var parseHtml = function(html) {
    return liftReaderDeferred(function(_, defer) {
        var handler = new(htmlparser.DefaultHandler)(function(error, dom) {
            return (function() {
                if(error) {
                    return defer.reject(error);
                } else {
                    return defer.resolve(dom);
                }
            })();
        }, {
            "verbose": false,
            "ignoreWhitespace": true
        });
        return new(htmlparser.Parser)((handler)).parseComplete(html);
    });
};
var extractTitle = function(dom) {
    var getTitle = function(els) {
        return htmlparser.DomUtils.getElementsByTagName("title", els);
    };
    var getText = function(els) {
        return htmlparser.DomUtils.getElementsByTagType("text", els);
    };
    return getText(getTitle(dom)).reduce(function(b, a) {
        return b + a.data;
    }, "");
};
var createPinchesRel = createRel("pinches");
var createAddsRel = createRel("adds");
var createViewsRel = createRel("views");
var getViewsRel = getRel("views");
var getPinchesRel = getRel("pinches");
var createUrl = function(url, key) {
    return ((function(){
        var __monad__ = readerDeferredMonad;
        
        return __monad__.bind(getUser(key), function(user) {
            
            return __monad__.bind((function(){
                var __monad__ = readerDeferredMonad;
                
                return __monad__.bind(fetchHtml(url), function(html) {
                    
                    return __monad__.bind(parseHtml(html), function(dom) {
                        
                        return __monad__.return(extractTitle(dom));
                    });
                });
            })(), function(title) {
                
                return __monad__.bind(liftReader(function(env) {
                    return deferredMonad.return(env.db.createNode({
                        "url": url,
                        "title": title
                    }));
                }), function(node) {
                    
                    return __monad__.bind(saveNode(node), function(_) {
                        
                        return __monad__.bind(createAddsRel(user, node), function(rel) {
                            
                            return __monad__.return({
                                "id": node.id,
                                "url": node.data.url,
                                "title": node.data.title
                            });
                        });
                    });
                });
            });
        });
    })());
};
var indexUrls = function(key) {
    return ((function(){
        var __monad__ = readerDeferredMonad;
        
        return __monad__.bind(getAllRel(key), function(res) {
            
            return __monad__.return(res);
        });
    })());
};
var createUrlView = function(id, key) {
    return ((function(){
        var __monad__ = readerDeferredMonad;
        
        return __monad__.bind(getUser(key), function(user) {
            
            return __monad__.bind(getNode(id), function(node) {
                
                return __monad__.bind(getViewsRel(key, node), function(views) {
                    
                    return __monad__.bind((function() {
                        if(views.length == 0) {
                            return createViewsRel(user, node);
                        } else {
                            return readerDeferredMonad.return(unit);
                        }
                    })(), function(res) {
                        
                        return __monad__.return(res);
                    });
                });
            });
        });
    })());
};
var createUrlPinch = function(id, key) {
    return ((function(){
        var __monad__ = readerDeferredMonad;
        
        return __monad__.bind(getUser(key), function(user) {
            
            return __monad__.bind(getNode(id), function(node) {
                
                return __monad__.bind(getPinchesRel(key, node), function(pinches) {
                    
                    return __monad__.bind((function() {
                        if(pinches.length == 0) {
                            return createPinchesRel(user, node);
                        } else {
                            return readerDeferredMonad.return(unit);
                        }
                    })(), function(res) {
                        
                        return __monad__.return(res);
                    });
                });
            });
        });
    })());
};
exports["runReader"] = runReader;;
exports["createUrl"] = createUrl;;
exports["indexUrls"] = indexUrls;;
exports["createUrlView"] = createUrlView;;
exports["createUrlPinch"] = createUrlPinch;;
