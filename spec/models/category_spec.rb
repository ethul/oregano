require "spec_helper"

describe Category do
  before do
    @key = "aaa"
    @item = "item"
    @items = ["item1","item2","item3"]
    @right = Right.new :right
    @mock_persist = mock("Persist")
  end
  describe "when a single item is saved into a new category" do
    it "should persist the item into the new category" do
      category = Category.new @key,@item
      category.should_receive(:persist).once.and_return(@mock_persist)
      @mock_persist.should_receive(:call).with(/:#{@key}$/,[@item]).once.and_return(@right)
      category.save
    end
  end
  describe "when multiple items are saved into a new category" do
    it "should persist the items into the new category" do
      category = Category.new @key,@items
      category.should_receive(:persist).once.and_return(@mock_persist)
      @mock_persist.should_receive(:call).with(/:#{@key}$/,@items).once.and_return(@right)
      category.save
    end
  end
  describe "when item is blank" do
    it "should not persist when the item is nil" do
      item = nil
      category = Category.new @key,item
      category.should_not_receive(:persist)
      category.save
    end
    it "should not persist when the item is an empty string" do
      item = ""
      category = Category.new @key,item
      category.should_not_receive(:persist)
      category.save
    end
    it "should not persist when the item is an empty array" do
      item = []
      category = Category.new @key,item
      category.should_not_receive(:persist)
      category.save
    end
  end
  describe "when the key is blank" do
    it "should not persist when the key is nil" do
      key = nil
      category = Category.new key,@item
      category.should_not_receive(:persist)
      category.save
    end
    it "should not persist when the key is empty" do
      key = ""
      category = Category.new key,@item
      category.should_not_receive(:persist)
      category.save
    end
    it "should not persist when the key is all spaces" do
      key = "     "
      category = Category.new key,@item
      category.should_not_receive(:persist)
      category.save
    end
  end
end
