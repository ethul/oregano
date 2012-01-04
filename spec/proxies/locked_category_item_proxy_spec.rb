require "spec_helper"

describe LockedCategoryItemProxy do
  before do
    @secret = "secret"
    @category_key = "category"
    @item_key = "item"
  end
  describe "when save is called on the proxy" do
    it "should create a category item relation" do
      Relations::CategoryItem.any_instance.should_receive(:save).once
      proxy = LockedCategoryItemProxy.new :secret => @secret, :category => @category_key, :item => @item_key
      proxy.save
    end
  end
end
