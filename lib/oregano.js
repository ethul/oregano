var crypto = require("crypto");
var deferred = require("JQDeferred");
var underscore = require("underscore");
var unit = {
    
};
var DB = function(a_0) {
    if(!(this instanceof DB)) {
        return new DB(a_0);
    }
    this._0 = a_0;
};
var dbMonad = {
    "return": function(a) {
        return function(c) {
            return DB(a);
        };
    },
    "bind": function(ma, f) {
        return function(c) {
            return (function() {
                if(ma instanceof DB) {
                    var a = ma._0;
                    return f(a)(c);
                }
            })();
        };
    }
};
var runDB = function(ma, c) {
    var res = ma(c);
    return (function() {
        if(res instanceof DB) {
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
var dbDeferredMonad = {
    "return": function(a) {
        return dbMonad.return(deferredMonad.return(a));
    },
    "bind": function(m, f) {
        return function(c) {
            var x = m(c);
            return DB(((function() {
                if(x instanceof DB) {
                    var ma = x._0;
                    return ((function(){
                var __monad__ = deferredMonad;
                
                return __monad__.bind(ma, function(a) {
                    var y = f(a)(c)
                    return (function() {
                        if(y instanceof DB) {
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
var liftDb = function(f) {
    return function(db) {
        return DB(f(db));
    };
};
var liftDeferred = function(f) {
    var defer = deferred();
    f(defer);
    return defer.promise();
};
var liftDbDeferred = function(f) {
    return liftDb(function(db) {
        return liftDeferred(function(defer) {
            return f(db, defer);
        });
    });
};
var sequenceDeferred = function(mas) {
    return liftDeferred(function(defer) {
        var master = deferred.when.apply(deferred, mas);
        master.done(function(_) {
            return defer.resolve(Array.prototype.slice.call(arguments));
        });
        return master.fail(defer.reject);
    });
};
var liftDbOp = function(op) {
    return liftDbDeferred(function(db, defer) {
        return op(db)(function(error, res) {
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
            var __monad__ = dbDeferredMonad;
            
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
var getAllAddsRel = function(key) {
    return ((function(){
        var __monad__ = dbDeferredMonad;
        var query = "START a=node:users(key={key}) MATCH a-[r:adds]->b RETURN b"
        return __monad__.bind(liftDbOp(function(db) {
            return function(handler) {
                return db.query(query, {
                    "key": key
                }, handler);
            };
        }), function(res) {
            
            return __monad__.return(res.map(function(a) {
                return a.b;
            }));
        });
    })());
};
var getRelForNodes = function(rel, nodes, key) {
    return liftDb(function(db) {
        return sequenceDeferred(nodes.map(function(a) {
            return runDB(rel(key, a), db);
        }));
    });
};
var getUser = function(key) {
    return liftDbDeferred(function(db, defer) {
        var query = "START a=node:users(key={key}) RETURN a";
        return db.query(query, {
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
var createPinchesRel = createRel("pinches");
var createAddsRel = createRel("adds");
var createViewsRel = createRel("views");
var getViewsRel = getRel("views");
var getPinchesRel = getRel("pinches");
var createUrl = function(url, key) {
    return ((function(){
        var __monad__ = dbDeferredMonad;
        
        return __monad__.bind(getUser(key), function(user) {
            
            return __monad__.bind(liftDb(function(db) {
                return deferredMonad.return(db.createNode({
                    "url": url
                }));
            }), function(node) {
                
                return __monad__.bind(saveNode(node), function(_) {
                    
                    return __monad__.bind(createAddsRel(user, node), function(rel) {
                        
                        return __monad__.return({
                            "id": node.id,
                            "url": node.data.url
                        });
                    });
                });
            });
        });
    })());
};
var indexUrls = function(key) {
    return ((function(){
        var __monad__ = dbDeferredMonad;
        
        return __monad__.bind(getAllAddsRel(key), function(adds) {
            
            return __monad__.bind(getRelForNodes(getViewsRel, adds, key), function(views) {
                
                return __monad__.bind(getRelForNodes(getPinchesRel, adds, key), function(pinches) {
                    var zipped = underscore.zip(adds, views, pinches)
                    return __monad__.return(zipped.map(function(tuple) {
                        return {
                            "id": tuple[0].id,
                            "url": tuple[0].data.url,
                            "relTypes": tuple.slice(1).reduce(function(b, a) {
                                return b.concat(a);
                            }).map(function(a) {
                                return a.type;
                            })
                        };
                    }));
                });
            });
        });
    })());
};
var createUrlView = function(id, key) {
    return ((function(){
        var __monad__ = dbDeferredMonad;
        
        return __monad__.bind(getUser(key), function(user) {
            
            return __monad__.bind(getNode(id), function(node) {
                
                return __monad__.bind(getViewsRel(key, node), function(views) {
                    
                    return __monad__.bind((function() {
                        if(views.length == 0) {
                            return createViewsRel(user, node);
                        } else {
                            return dbDeferredMonad.return(unit);
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
        var __monad__ = dbDeferredMonad;
        
        return __monad__.bind(getUser(key), function(user) {
            
            return __monad__.bind(getNode(id), function(node) {
                
                return __monad__.bind(getPinchesRel(key, node), function(pinches) {
                    
                    return __monad__.bind((function() {
                        if(pinches.length == 0) {
                            return createPinchesRel(user, node);
                        } else {
                            return dbDeferredMonad.return(unit);
                        }
                    })(), function(res) {
                        
                        return __monad__.return(res);
                    });
                });
            });
        });
    })());
};
exports["runDB"] = runDB;;
exports["createUrl"] = createUrl;;
exports["indexUrls"] = indexUrls;;
exports["createUrlView"] = createUrlView;;
exports["createUrlPinch"] = createUrlPinch;;
