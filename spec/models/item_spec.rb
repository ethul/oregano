require "spec_helper"

describe Item do
  describe "when an item is saved" do
    before do
      @key = "aaa"
      @value = "value"
      @right = Right.new :right
      @mock_persist = mock("Persist")
    end
    it "should persist the value" do
      item = Item.new @key,@value
      item.should_receive(:persist).once.and_return(@mock_persist)
      @mock_persist.should_receive(:call).with(/:#{@key}$/,@value).once.and_return(@right)
      item.save
    end
    it "should fail validation for empty keys" do
      key = ""
      item = Item.new key,@value
      item.should_not_receive(:persist)
      item.save.class.should == Left
    end
    it "should fail validation for empty values" do
      value = ""
      item = Item.new @key,value
      item.should_not_receive(:persist)
      item.save.class.should == Left
    end
    it "should fail validation for nil keys" do
      key = nil
      item = Item.new key,@value
      item.should_not_receive(:persist)
      item.save.class.should == Left
    end
    it "should fail validation for nil values" do
      value = nil
      item = Item.new @key,value
      item.should_not_receive(:persist)
      item.save.class.should == Left
    end
    it "should format values to utf-8" do
      value = "\xfc".force_encoding("ISO-8859-1")
      expected_byte = value.bytes.first
      item = Item.new @key,value
      item.should_receive(:persist).once.and_return(->a,b {
        Right.new expected_byte.should_not == b.bytes.first
      })
      item.save
    end
    describe "when the key is blank" do
      it "should not persist when the key is nil" do
        key = nil
        item = Item.new key,@value
        item.should_not_receive(:persist)
        item.save
      end
      it "should not persist when the key is empty" do
        key = ""
        item = Item.new key,@value
        item.should_not_receive(:persist)
        item.save
      end
      it "should not persist when the key is all spaces" do
        key = "     "
        item = Item.new key,@value
        item.should_not_receive(:persist)
        item.save
      end
    end
  end
end
