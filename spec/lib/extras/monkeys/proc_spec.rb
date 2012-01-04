describe Proc do
  describe "when composed" do
    it "should allow for function composition" do
      f = ->a {a + 10}
      g = ->a {a + 20}
      h = f * g
      h.(5).should == f.(g.(5))
    end
  end
end
