require "spec_helper"

describe NonEmptyListValidator do
  before do
    @validator = Object.new
    @validator.extend NonEmptyListValidator
  end

  describe "when the list is empty" do
    it "should be invalid" do
      list = []
      @validator.validate_non_empty_list.(list).class.should == Left
    end
  end

  describe "when the list is nil" do
    it "should be invalid" do
      list = nil
      @validator.validate_non_empty_list.(list).class.should == Left
    end
  end

  describe "when the value is not a list" do
    it "should be invalid" do
      list = 20
      @validator.validate_non_empty_list.(list).class.should == Left
    end
  end

  describe "when the list is not empty" do
    it "should be valid" do
      list = ["a"]
      @validator.validate_non_empty_list.(list).class.should == Right
    end
  end
end
