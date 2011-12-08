require "spec_helper"

describe Monads do
  describe "when maybe's bind is invoked" do
    it "should hold to left identity: forall f,a . f(a) == return(a).bind(f)" do
      f = ->(a) {Just.new(a)}
      a = 10
      f.(a).get.should == Just.new(a).bind(f).get
    end
    it "should hold to right identity: forall ma . ma == ma.bind(x -> return(x))" do
      a = 10
      Just.new(a).get.should == Just.new(a).bind(->(x){Maybe.return(x)}).get
      Nothing.new.class.name.should == Nothing.new.bind(->(x){Maybe.return(x)}).class.name
    end
    it "should hold to associativity: forall ma,f,g . (ma.bind(f)).bind(g) == ma.bind(x -> f(x).bind(g))" do
      a = 10
      f = ->(a) {Just.new(a+10)}
      g = ->(a) {Just.new(a+30)}
      (Just.new(a).bind(f)).bind(g).get.should == Just.new(a).bind(->(x){f.(x).bind(g)}).get
      (Nothing.new.bind(f)).bind(g).class.name.should == Nothing.new.bind(->(x){f.(x).bind(g)}).class.name
    end
  end

  describe "when either's bind is invoked" do
    it "should hold to left identity: forall f,a . f(a) == return(a).bind(f)" do
      a = 10

      f = ->(x) {Right.new(x)}
      f.(a).get.should == Either.return(a).bind(f).get

      f = ->(x) {Left.new(x)}
      f.(a).get.should == Either.return(a).bind(f).get
    end

    it "should hold to right identity: forall ma . ma == ma.bind(x -> return(x))" do
      a = 10
      Right.new(a).get.should == Right.new(a).bind(->(x){Either.return(x)}).get
      Left.new(a).get.should == Left.new(a).bind(->(x){Either.return(x)}).get
    end

    it "should hold to associativity: forall ma,f,g . (ma.bind(f)).bind(g) == ma.bind(x -> f(x).bind(g))" do
      a = 10

      f = ->(a) {Right.new(a+10)}
      g = ->(a) {Right.new(a+30)}
      (Right.new(a).bind(f)).bind(g).get.should == Right.new(a).bind(->(x){f.(x).bind(g)}).get

      f = ->(a) {Left.new(a+10)}
      g = ->(a) {Right.new(a+30)}
      (Right.new(a).bind(f)).bind(g).get.should == Right.new(a).bind(->(x){f.(x).bind(g)}).get

      f = ->(a) {Left.new(a+10)}
      g = ->(a) {Left.new(a+30)}
      (Right.new(a).bind(f)).bind(g).get.should == Right.new(a).bind(->(x){f.(x).bind(g)}).get

      f = ->(a) {Right.new(a+10)}
      g = ->(a) {Left.new(a+30)}
      (Right.new(a).bind(f)).bind(g).get.should == Right.new(a).bind(->(x){f.(x).bind(g)}).get

      f = ->(a) {Right.new(a+10)}
      g = ->(a) {Right.new(a+30)}
      (Left.new(a).bind(f)).bind(g).get.should == Left.new(a).bind(->(x){f.(x).bind(g)}).get

      f = ->(a) {Right.new(a+10)}
      g = ->(a) {Left.new(a+30)}
      (Left.new(a).bind(f)).bind(g).get.should == Left.new(a).bind(->(x){f.(x).bind(g)}).get

      f = ->(a) {Left.new(a+10)}
      g = ->(a) {Right.new(a+30)}
      (Left.new(a).bind(f)).bind(g).get.should == Left.new(a).bind(->(x){f.(x).bind(g)}).get

      f = ->(a) {Left.new(a+10)}
      g = ->(a) {Left.new(a+30)}
      (Left.new(a).bind(f)).bind(g).get.should == Left.new(a).bind(->(x){f.(x).bind(g)}).get
    end
  end
end
