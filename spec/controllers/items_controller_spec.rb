require "spec_helper"

describe ItemsController do
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

    before do
      @user_key = "user_key"
      session[:user_key] = @user_key
    end

    before do
      @mock_user = mock("User")
      @user_value = "user_value"
    end

    describe "when a valid item is posted" do
      before do
        @mock_acquire.stub(:set => true)
      end
      before do
        User.should_receive(:load).once.with(@user_key).and_return(Right.new @mock_user)
        @mock_user.should_receive(:value).once.and_return(@user_value)
      end
      it "should have status created" do
        post :create, {:value => "value"}
        response.status.should == 201
      end
      it "should return the key in a json object" do
        value = "value"
        post :create, {:value => value}
        JSON.parse(response.body).has_key?("key").should be_true
      end
      it "should return the value in a json object" do
        value = "value"
        post :create, {:value => value}
        JSON.parse(response.body).has_key?("value").should be_true
        JSON.parse(response.body)["value"].should == value
      end
      it "should return the public key in the json object" do
        public_key = "public_key"
        value = "value"
        Oregano::Redis::Generators::UniqueId.any_instance.stub(:generate => public_key)
        post :create, {:value => value}
        JSON.parse(response.body).has_key?("key").should be_true
        JSON.parse(response.body)["key"].should == public_key
      end
    end
  end
end
