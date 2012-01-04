require "spec_helper"

describe CategoriesController do
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

    describe "when a new category is created with no items" do
      before do
        @mock_acquire.should_not_receive(:sadd)
      end
      before do
        User.should_receive(:load).once.with(@user_key).and_return(Right.new @mock_user)
        @mock_user.should_receive(:value).once.and_return(@user_value)
      end
      it "should have status created" do
        post :create
        response.status.should == 201
      end
      it "should return the id in a json object" do
        post :create
        JSON.parse(response.body).has_key?("key").should be_true
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
