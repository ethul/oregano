require "spec_helper"

describe Applicatives do
  describe "when maybe's ap is invoked" do
    it "should hold to identity: forall a . a == pure(identity).ap(a)" do
      id = ->(a) {a}
      x = Just.new(10)
      x.get.should == Maybe.pure(id).ap(x).get
      x = Nothing.new
      x.class.name.should == Maybe.pure(id).ap(x).class.name
    end
    it "should hold to composition: forall af,ag,a . af.ap(ag.ap(a)) == pure(compose).ap(af).ap(ag).ap(a)" do
      compose = ->(a,b){->(x){a.(b.(x))}}

      af = Just.new(->(a){a+4})
      ag = Just.new(->(a){a+6})
      a = Just.new(5)
      af.ap(ag.ap(a)).get.should == Maybe.pure(compose).ap(af).ap(ag).ap(a).get

      af = Nothing.new
      ag = Just.new(->(a){a+6})
      a = Just.new(5)
      af.ap(ag.ap(a)).class.name.should == Maybe.pure(compose).ap(af).ap(ag).ap(a).class.name

      af = Just.new(->(a){a+4})
      ag = Nothing.new
      a = Just.new(5)
      af.ap(ag.ap(a)).class.name.should == Maybe.pure(compose).ap(af).ap(ag).ap(a).class.name

      af = Just.new(->(a){a+4})
      ag = Just.new(->(a){a+6})
      a = Nothing.new
      af.ap(ag.ap(a)).class.name.should == Maybe.pure(compose).ap(af).ap(ag).ap(a).class.name

      af = Nothing.new
      ag = Nothing.new
      a = Just.new(5)
      af.ap(ag.ap(a)).class.name.should == Maybe.pure(compose).ap(af).ap(ag).ap(a).class.name

      af = Nothing.new
      ag = Just.new(->(a){a+6})
      a = Nothing.new
      af.ap(ag.ap(a)).class.name.should == Maybe.pure(compose).ap(af).ap(ag).ap(a).class.name

      af = Nothing.new
      ag = Nothing.new
      a = Nothing.new
      af.ap(ag.ap(a)).class.name.should == Maybe.pure(compose).ap(af).ap(ag).ap(a).class.name
    end
    it "should hold to homomorphism: forall f a . pure(f).ap(pure(a)) == pure(f(a))" do
      f = ->(a){a+20}
      a = 10
      Maybe.pure(f).ap(Maybe.pure(10)).get.should == Maybe.pure(f.(a)).get
    end
    it "should hold to interchange: forall af a . af.ap(pure(a)) == pure(->(f) {f.(a)}).ap(af)" do
      f = ->(a){a+10}
      a = 30
      Just.new(f).ap(Maybe.pure(a)).get.should == Maybe.pure(->(g){g.(a)}).ap(Just.new(f)).get
      Nothing.new.ap(Maybe.pure(a)).class.name.should == Maybe.pure(->(g){g.(a)}).ap(Nothing.new).class.name
    end
    it "should be the same as fmap for all f,x: pure(f).ap(x) == x.fmap(f)" do
      f = ->(a) {a+5}
      x = Just.new(20)
      Maybe.pure(f).ap(x).get.should == x.fmap(f).get
      Maybe.pure(f).ap(Nothing.new).class.name.should == Nothing.new.fmap(f).class.name
    end
    it "should hold to basic use cases" do
      fab = Just.new(->(a) {->(b) {a+b}})
      fab.ap(Just.new(10)).ap(Just.new(5)).get.should == 15
      fab.ap(Nothing.new).ap(Just.new(5)).class.name.should == Nothing.name
      fab.ap(Just.new(10)).ap(Nothing.new).class.name.should == Nothing.name
    end
  end

  describe "when either's ap is invoked" do
    it "should hold to identity: forall a . a == pure(identity).ap(a)" do
      id = ->(a) {a}

      x = Right.new(10)
      x.get.should == Either.pure(id).ap(x).get

      y = Left.new(10)
      y.get.should == Either.pure(id).ap(y).get
    end

    it "should hold to composition: forall af,ag,a . af.ap(ag.ap(a)) == pure(compose).ap(af).ap(ag).ap(a)" do
      compose = ->(a,b){->(x){a.(b.(x))}}

      af = Right.new(->(a){a+4})
      ag = Right.new(->(a){a+6})
      a = Right.new(5)
      af.ap(ag.ap(a)).get.should == Either.pure(compose).ap(af).ap(ag).ap(a).get

      af = Left.new(->(a){a+4})
      ag = Right.new(->(a){a+6})
      a = Right.new(5)
      af.ap(ag.ap(a)).get.should == Either.pure(compose).ap(af).ap(ag).ap(a).get

      af = Right.new(->(a){a+4})
      ag = Left.new(->(a){a+6})
      a = Right.new(5)
      af.ap(ag.ap(a)).get.should == Either.pure(compose).ap(af).ap(ag).ap(a).get

      af = Right.new(->(a){a+4})
      ag = Right.new(->(a){a+6})
      a = Left.new(5)
      af.ap(ag.ap(a)).get.should == Either.pure(compose).ap(af).ap(ag).ap(a).get

      af = Left.new(->(a){a+4})
      ag = Left.new(->(a){a+6})
      a = Right.new(5)
      af.ap(ag.ap(a)).get.should == Either.pure(compose).ap(af).ap(ag).ap(a).get

      af = Left.new(->(a){a+4})
      ag = Right.new(->(a){a+6})
      a = Left.new(5)
      af.ap(ag.ap(a)).get.should == Either.pure(compose).ap(af).ap(ag).ap(a).get

      af = Right.new(->(a){a+4})
      ag = Left.new(->(a){a+6})
      a = Left.new(5)
      af.ap(ag.ap(a)).get.should == Either.pure(compose).ap(af).ap(ag).ap(a).get

      af = Left.new(->(a){a+4})
      ag = Left.new(->(a){a+6})
      a = Left.new(5)
      af.ap(ag.ap(a)).get.should == Either.pure(compose).ap(af).ap(ag).ap(a).get
    end

    it "should hold to homomorphism: forall f a . pure(f).ap(pure(a)) == pure(f(a))" do
      f = ->(a){a+20}
      a = 10
      Either.pure(f).ap(Either.pure(10)).get.should == Either.pure(f.(a)).get
    end

    it "should hold to interchange: forall af a . af.ap(pure(a)) == pure(->(f) {f.(a)}).ap(af)" do
      f = ->(a){a+10}
      a = 30
      Right.new(f).ap(Either.pure(a)).get.should == Either.pure(->(g){g.(a)}).ap(Right.new(f)).get
      Left.new(f).ap(Either.pure(a)).get.should == Either.pure(->(g){g.(a)}).ap(Left.new(f)).get
    end

    it "should be the same as fmap for all f,x: pure(f).ap(x) == x.fmap(f)" do
      f = ->(a) {a+5}

      x = Right.new(20)
      Either.pure(f).ap(x).get.should == x.fmap(f).get

      y = Left.new(20)
      Either.pure(f).ap(y).get.should == y.fmap(f).get
    end

    it "should accumulate errors when the type of e responds to concat" do
      result = Either.pure(->(a,b,c){"test"}).ap(Left.new ["error1"]).ap(Left.new ["error2"]).ap(Left.new ["error3"]).get
      result.should == ["error1","error2","error3"]
    end
  end
end
