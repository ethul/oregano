require "spec_helper"

describe Users::LocalsController do
  describe :create do
    before do
      Rails.stub(:env => stub(:development? => true))
    end
    before do
      @mock_acquire = mock
      User.any_instance.stub(:acquire => @mock_acquire)
    end
    before do
      @mock_acquire.stub(:setnx => true)
    end
    describe "when a user is created" do
      it "should set the user_key in the session" do
        post :create
        session.should have_key :user_key
      end
      it "should set the user_key value to be the local user id" do
        post :create
        session[:user_key].should == Users::LocalsController::USER_ID
      end
      it "should have response status created" do
        post :create
        response.status.should == 201
      end
    end
  end
end
