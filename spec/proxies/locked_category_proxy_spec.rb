describe LockedCategoryProxy do
  describe "when save is called on the proxy" do
    before do
      @secret = "secret"
      @items = ["item"]
    end
    it "should create an item with the given value" do
      Category.should_receive(:new).with(anything,@items).once
      LockedCategoryProxy.new :secret => @secret, :items => @items
    end
    it "should create an item where the key is based on a secret" do
      public_key = "public_key"
      expected = Digest::SHA1.hexdigest @secret + public_key
      Category.should_receive(:new).with(expected,anything).once
      LockedCategoryProxy.new :secret => @secret, :items => @items, :public_key => public_key
    end
    it "should serialize to json with the public key" do
      public_key = "public_key"
      proxy = LockedCategoryProxy.new :secret => @secret, :items => @items, :public_key => public_key
      JSON.parse(proxy.to_json).should include("key" => public_key)
    end
  end
end
