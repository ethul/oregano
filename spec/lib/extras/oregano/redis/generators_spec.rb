describe Oregano::Redis::Generators do
  describe Oregano::Redis::Generators::UniqueId do
    describe "when a unique id is generated" do
      it "should be a sha1 hex hash" do
        Oregano::Redis::Generators::UniqueId.new.generate.should match /[a-z0-9]+/i
      end
    end
  end
  describe Oregano::Redis::Generators::PairedId do
    describe "when a paired id is generated without a given key" do
      it "should be a sha1 hex hash" do
        secret = "secret"
        id = Oregano::Redis::Generators::PairedId.new(secret).generate
        id.should match /[a-z0-9]+/i
      end
    end
    describe "when a paired id is generated with a given key" do
      it "should be a sha1 hex hash matching secret + key" do
        secret = "secret"
        key = "key"
        id = Oregano::Redis::Generators::PairedId.new(secret,key).generate
        id.should == Digest::SHA1.hexdigest(secret + key)
      end
    end
  end
  describe Oregano::Redis::Generators::MappedId do
    describe "when a mapped id is generated" do
      it "should generate the same mapping for a seed" do
        generator = Oregano::Redis::Generators::MappedId.new "seed"
        generator.generate.should == generator.generate
      end
    end
  end
end
