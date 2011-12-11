require "spec_helper"

describe LockedUserCategoryProxy do
  before do
    @secret = "secret"
    @user_key = "user"
    @category_key = "category"
  end
  describe "when save is called on the proxy" do
    it "should create a user category relation" do
      Relations::UserCategory.any_instance.should_receive(:save).once
      proxy = LockedUserCategoryProxy.new :secret => @secret, :user => @user_key, :category => @category_key
      proxy.save
    end
    it "should use the private user key" do
      private_user_key = "aaa"
      proxy = LockedUserCategoryProxy.new :secret => @secret, :user => @user_key, :category => @category_key, :private_user_key => private_user_key
      mock_persist = mock("Persist")
      Relations::UserCategory.any_instance.should_receive(:persist).once.and_return(mock_persist)
      mock_persist.should_receive(:call).with("user_categories:#{private_user_key}",anything).once
      proxy.save
    end
    it "should use the private category key" do
      private_category_key = "bbb"
      proxy = LockedUserCategoryProxy.new :secret => @secret, :user => @user_key, :category => @category_key, :private_category_key => private_category_key
      mock_persist = mock("Persist")
      Relations::UserCategory.any_instance.should_receive(:persist).once.and_return(mock_persist)
      mock_persist.should_receive(:call).with(anything,private_category_key).once
      proxy.save
    end
  end
end
