describe Oregano::Redis::Fetchables do
  describe Oregano::Redis::Fetchables::String do
    describe "when a string value is fetched" do
      before do
        @mock_acquire = mock
        MockStringFetchable.stub(:acquire => @mock_acquire)
      end
      it "should return the value" do
        value = "value"
        key = "key"
        @mock_acquire.should_receive(:get).with(key).once.and_return(value)
        MockStringFetchable.fetch.(key).fmap(->a {a.should == value})
      end
      it "should return a failure when the key does not exist" do
        value = nil
        key = "key"
        @mock_acquire.should_receive(:get).with(key).once.and_return(value)
        MockStringFetchable.fetch.(key).class.should == Left
      end
      it "should raise a error when the value cannot be fetched" do
        key = "key"
        @mock_acquire.should_receive(:get).with(key).once.and_raise("error")
        MockStringFetchable.fetch.(key).class.should == Left
      end
    end
  end
end

class MockStringFetchable
  extend Oregano::Redis::Fetchables::String
end
