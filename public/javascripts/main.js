(function() {
  var template = Handlebars.template, templates = Handlebars.templates = Handlebars.templates || {};
templates['header'] = template(function (Handlebars,depth0,helpers,partials,data) {
  helpers = helpers || Handlebars.helpers;
  var foundHelper, self=this;


  return "<h1>\n  <i class=icon-leaf></i>\n  Oregano\n</h1>\n<h2>A pinch at a time.</h2>\n<div id=new-url></div>\n";});
})();
(function() {
  var template = Handlebars.template, templates = Handlebars.templates = Handlebars.templates || {};
templates['new_url'] = template(function (Handlebars,depth0,helpers,partials,data) {
  helpers = helpers || Handlebars.helpers;
  var foundHelper, self=this;


  return "<form>\n  <input id=new-url-input type=url name=url\n      placeholder=\"type a url, then press enter\" autofocus></input>\n</form>\n";});
})();
(function() {
  var template = Handlebars.template, templates = Handlebars.templates = Handlebars.templates || {};
templates['url'] = template(function (Handlebars,depth0,helpers,partials,data) {
  helpers = helpers || Handlebars.helpers;
  var buffer = "", stack1, foundHelper, self=this, functionType="function", helperMissing=helpers.helperMissing, undef=void 0, escapeExpression=this.escapeExpression;


  buffer += "<article class=url>\n  <h1>";
  stack1 = depth0;
  if(typeof stack1 === functionType) { stack1 = stack1.call(depth0, { hash: {} }); }
  else if(stack1=== undef) { stack1 = helperMissing.call(depth0, "this", { hash: {} }); }
  buffer += escapeExpression(stack1) + "</h1>\n  <a href=\"";
  stack1 = depth0;
  if(typeof stack1 === functionType) { stack1 = stack1.call(depth0, { hash: {} }); }
  else if(stack1=== undef) { stack1 = helperMissing.call(depth0, "this", { hash: {} }); }
  buffer += escapeExpression(stack1) + "\">View</a>\n</article>\n";
  return buffer;});
})();
(function() {
  var template = Handlebars.template, templates = Handlebars.templates = Handlebars.templates || {};
templates['urls'] = template(function (Handlebars,depth0,helpers,partials,data) {
  helpers = helpers || Handlebars.helpers;
  var buffer = "", stack1, stack2, foundHelper, tmp1, self=this, functionType="function", helperMissing=helpers.helperMissing, undef=void 0, escapeExpression=this.escapeExpression;

function program1(depth0,data) {
  
  var buffer = "", stack1;
  buffer += "\n  <article class=url>\n    <h1>";
  stack1 = depth0;
  if(typeof stack1 === functionType) { stack1 = stack1.call(depth0, { hash: {} }); }
  else if(stack1=== undef) { stack1 = helperMissing.call(depth0, "this", { hash: {} }); }
  buffer += escapeExpression(stack1) + "</h1>\n    <a href=\"";
  stack1 = depth0;
  if(typeof stack1 === functionType) { stack1 = stack1.call(depth0, { hash: {} }); }
  else if(stack1=== undef) { stack1 = helperMissing.call(depth0, "this", { hash: {} }); }
  buffer += escapeExpression(stack1) + "\">View</a>\n  </article>\n";
  return buffer;}

  stack1 = depth0;
  stack2 = helpers.each;
  tmp1 = self.program(1, program1, data);
  tmp1.hash = {};
  tmp1.fn = tmp1;
  tmp1.inverse = self.noop;
  stack1 = stack2.call(depth0, stack1, tmp1);
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\n";
  return buffer;});
})();
(function() {
var NewUrl = function(a_0) {
    if(!(this instanceof NewUrl)) {
        return new NewUrl(a_0);
    }
    this._0 = a_0;
};
var unit = {
    
};
var iife = function(f) {
    return f();
};
var bus = new(Bacon).Bus();
var headerTemplate = "body > header";
var newUrlTemplate = "#new-url";
var newUrlInput = "#new-url-input";
var newUrlTemplateForm = newUrlTemplate + " form";
var urlsTemplate = "#urls";
var deferredMonad = {
    "return": function(a) {
        return $.when(a);
    },
    "bind": function(m, f) {
        var defer = $.Deferred();
        m.done(function(a) {
            return f(a).done(defer.resolve);
        });
        return defer.promise();
    }
};
var renderHeader = function() {
    return $(document).ready(function() {
        var el = $(headerTemplate);
        el.hide();
        el.html(Handlebars.templates.header());
        return el.fadeIn();
    });
};
var renderNewUrl = function() {
    return $(document).ready(function() {
        var el = $(newUrlTemplate);
        el.hide();
        el.html(Handlebars.templates.new_url());
        el.fadeIn();
        var input = $(newUrlInput);
        input.focus();
        var form = $(newUrlTemplateForm);
        var submits = form.asEventStream("submit");
        return bus.plug(submits.map(function(e) {
            e.preventDefault();
            return NewUrl(form.serializeObject());
        }));
    });
};
var renderUrls = function(urls) {
    return $(document).ready(function() {
        var el = $(urlsTemplate);
        el.hide();
        el.html(Handlebars.templates.urls(urls));
        return el.fadeIn();
    });
};
var renderUrl = function(url) {
    return $(document).ready(function() {
        var template = $(urlsTemplate);
        var el = $(Handlebars.templates.url(url));
        el.hide();
        template.append(el);
        return el.fadeIn();
    });
};
bus.onValue(function(e) {
    return (function() {
        if(e instanceof NewUrl) {
            var a = e._0;
            return iife(function() {
        $(newUrlTemplateForm)[0].reset();
        $.post("/urls", a);
        return renderUrl(a.url);
    });
        }
    })();
});
renderHeader();
renderNewUrl();
(function(){
    var __monad__ = deferredMonad;
    
    return __monad__.bind($.get("/urls"), function(urls) {
        
        return __monad__.return(renderUrls(urls));
    });
})();
})();
