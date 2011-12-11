describe LockedItemProxy do
  describe "when save is called on the proxy" do
    before do
      @secret = "secret"
      @value = "value"
    end
    it "should create an item with the given value" do
      Item.should_receive(:new).with(anything,@value).once
      LockedItemProxy.new :secret => @secret, :value => @value
    end
    it "should create an item where the key is based on a secret" do
      public_key = "public_key"
      expected = Digest::SHA1.hexdigest @secret + public_key
      Item.should_receive(:new).with(expected,anything).once
      LockedItemProxy.new :secret => @secret, :value => @value, :public_key => public_key
    end
    it "should serialize to json with the public key" do
      public_key = "public_key"
      proxy = LockedItemProxy.new :secret => @secret, :value => @value, :public_key => public_key
      JSON.parse(proxy.to_json).should include("key" => public_key)
    end
  end
end
