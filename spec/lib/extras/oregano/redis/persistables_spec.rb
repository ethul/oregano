describe Oregano::Redis::Persistables do
  describe Oregano::Redis::Persistables::String do
    describe "when a string value is persisted" do
      before do
        @mock_acquire = mock
        @persistable = MockStringPersistable.new
        @persistable.stub(:acquire => @mock_acquire)
      end
      before do
        @key = "key"
        @value = "value"
      end
      it "should have a successful result" do
        expected = :persist_success
        @mock_acquire.should_receive(:set).with(@key,@value).once.and_return(expected)
        result = @persistable.persist.(@key, @value)
        result.fmap(->a {a.should == expected})
      end
      it "should have a persistence failure on set failure" do
        expected = false
        @mock_acquire.should_receive(:set).with(@key,@value).once.and_return(expected)
        result = @persistable.persist.(@key, @value)
        result.fmap(->a {a.should == :persist_failure})
      end
      it "should be a error on set exception" do
        expected = "set error"
        @mock_acquire.should_receive(:set).with(@key,@value).once.and_raise(expected)
        result = @persistable.persist.(@key, @value)
        result.class.should == Left
        result.fmap(->a {a.should == expected})
      end
    end
  end
  describe Oregano::Redis::Persistables::Set do
    describe "when a set is persisted" do
      before do
        @mock_acquire = mock
        @persistable = MockSetPersistable.new
        @persistable.stub(:acquire => @mock_acquire)
      end
      before do
        @key = "key"
        @value1 = "value1"
        @value2 = "value2"
        @value3 = "value3"
      end
      it "should have a successful result with one value" do
        expected = :persist_success
        @mock_acquire.should_receive(:sadd).with(@key,@value1).once.and_return(expected)
        result = @persistable.persist.(@key, @value1)
        result.fmap(->a {a.should == expected})
      end
      it "should have a successful result with many values" do
        expected = :persist_success
        @mock_acquire.should_receive(:sadd).with(@key,[@value1,@value2,@value3]).once.and_return(expected)
        result = @persistable.persist.(@key,[@value1,@value2,@value3])
        result.fmap(->a {a.should == expected})
      end
    end
  end
  describe Oregano::Redis::Persistables::StringNx do
    describe "when a string nx value is persisted" do
      before do
        @mock_acquire = mock
        @persistable = MockStringNxPersistable.new
        @persistable.stub(:acquire => @mock_acquire)
      end
      before do
        @key = "key"
        @value = "value"
      end
      it "should have a successful result when key does not exist" do
        expected = :persist_success
        @mock_acquire.should_receive(:setnx).with(@key,@value).once.and_return(expected)
        result = @persistable.persist.(@key, @value)
        result.fmap(->a {a.should == expected})
      end
      it "should have a failure result when key does exist" do
        expected = false
        @mock_acquire.should_receive(:setnx).with(@key,@value).once.and_return(expected)
        result = @persistable.persist.(@key, @value)
        result.class.should == Left
      end
    end
  end
end

class MockStringPersistable
  include Oregano::Redis::Persistables::String
end

class MockStringNxPersistable
  include Oregano::Redis::Persistables::StringNx
end

class MockSetPersistable
  include Oregano::Redis::Persistables::Set
end
