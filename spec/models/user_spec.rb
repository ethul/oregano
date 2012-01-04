require "spec_helper"

describe User do
  before do
    @key = "aaa"
    @mock_persist = mock("Persist")
  end
  describe "when a new user is saved" do
    before do
      @mapped = Oregano::Redis::Generators::MappedId.new(@key).generate
      @value = "bbb"
      Oregano::Redis::Generators::UniqueId.stub(:new => stub(:generate => @value))
    end
    it "should persist the user" do
      user = User.new @key
      user.should_receive(:persist).once.and_return(@mock_persist)
      @mock_persist.should_receive(:call).with(/:#{@mapped}$/,@value).once.and_return(Right.new :right)
      user.save.get.key.should == @key
    end
    it "should fail with a nil key" do
      user = User.new nil
      user.should_not_receive(:persist)
      user.save
    end
    it "should fail with a non-hex value" do
      user = User.new @key,"!!@20lfefj"
      user.should_not_receive(:persist)
      user.save
    end
    it "should fail validation for empty ids" do
      user = User.new ""
      user.should_not_receive(:persist)
      user.save
    end
  end
  describe "when an existing user is saved" do
    it "should not persist, but be successful" do
      user = User.new @key
      user.should_receive(:persist).once.and_return(@mock_persist)
      @mock_persist.should_receive(:call).with(anything,anything).once.and_return(Left.new :persist_failure)
      user.save.fmap(->a {a.key.should == @key}).class.should == Right
    end
  end
  describe "when a user is retrieved for an id" do
    before do
      @mock_acquire = mock("Acquire")
    end
    before do
      @mock_mapped_id = mock("MappedId")
      Oregano::Redis::Generators::MappedId.stub(:new => @mock_mapped_id)
    end
    it "should fetch the user associated to the key" do
      value = "value"
      User.should_receive(:acquire).once.and_return(@mock_acquire)
      @mock_acquire.should_receive(:get).with(/:#{@key}$/).and_return(value)
      @mock_mapped_id.should_receive(:generate).once.and_return(@key)
      User.load(@key).fmap(->a{a.value.should == value}).class.should == Right
    end
    it "should fail to fetch a user for a non hex key" do
      key = "vfoeifj@232"
      value = "value"
      @mock_mapped_id.should_receive(:generate).once.and_return(key)
      User.should_not_receive(:fetch)
      User.load key
    end
  end
end
