require "spec_helper"

describe Relations::CategoryItem do
  before do
    @mock_persist = mock("Persist")
  end

  describe "when a category item relation is saved" do
    before do
      @category = "aaa"
      @item = "bbb"
    end

    it "should persist the item key into the category's set" do
      relation = Relations::CategoryItem.new @category,@item
      relation.should_receive(:persist).once.and_return(@mock_persist)
      @mock_persist.should_receive(:call).with(/:#{@category}$/,@item).once.and_return(Right.new :right)
      relation.save
    end

    it "should not persist with a non hexadecimal category" do
      relation = Relations::CategoryItem.new "aaa\nbbb",@item
      relation.should_not_receive(:persist)
      relation.save
    end

    it "should not persist with a non hexadecimal item" do
      relation = Relations::CategoryItem.new @category,"aaa\nbbb"
      relation.should_not_receive(:persist)
      relation.save
    end
  end
end
