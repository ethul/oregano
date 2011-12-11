require "spec_helper"

describe Relations::CategoryItemsController do
  before do
    controller.stub(:validate_session! => true)
  end
  before do
    @request.accept = "application/json"
  end

  describe :create do
    before do
      @mock_acquire = mock
      Oregano::Redis.class_variable_set :@@connection, @mock_acquire
    end

    describe "when a new relation is created" do
      before do
        @user_key = "aaa"
        @user_value = "bbb"
        @user_secret = "secret"
        controller.session[:user_key] = @user_key
      end
      before do
        @mock_user = mock("User")
        User.should_receive(:load).with(@user_key).once.and_return(Right.new @mock_user)
      end
      before do
        @mock_user.should_receive(:value).once.and_return(@user_value)
      end
      it "should have status created" do
        @mock_acquire.should_receive(:sadd).with(/[a-zA-Z\d]+:[a-zA-Z\d]+/,anything).once
        post :create, {:category => "aaa", :item => "bbb"}
        response.status.should == 201
      end
    end
  end
end
