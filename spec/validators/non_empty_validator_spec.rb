require "spec_helper"

describe NonEmptyValidator do
  before do
    @validator = Object.new
    @validator.extend NonEmptyValidator
  end

  describe "when the value has a character" do
    it "should be valid" do
      value = "a"
      @validator.validate_non_empty.(value).class.should == Right
    end
  end

  describe "when the value is empty" do
    it "should not be valid with a nil value" do
      value = nil
      @validator.validate_non_empty.(value).class.should == Left
    end
    it "should not be valid with no value" do
      value = ""
      @validator.validate_non_empty.(value).class.should == Left
    end
    it "should not be valid with only spaces" do
      value = "     "
      @validator.validate_non_empty.(value).class.should == Left
    end
    it "should not be valid with only tabs" do
      value = "\t\t\t"
      @validator.validate_non_empty.(value).class.should == Left
    end
  end
end
