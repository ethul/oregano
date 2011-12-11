require "spec_helper"

describe HexValidator do
  before do
    @validator = Object.new
    @validator.extend HexValidator
  end

  describe "when the value contains only hexidecimal characters" do
    it "should be valid" do
      value = "abc235893598aaabc"
      @validator.validate_hex.(value).class.should == Right
    end
  end

  describe "when the value is empty" do
    it "should be valid" do
      value = ""
      @validator.validate_hex.(value).class.should == Right
    end
  end

  describe "when the value is nil" do
    it "should be valid" do
      value = nil
      @validator.validate_hex.(value).class.should == Right
    end
  end

  describe "when the value is blank" do
    it "should not be valid" do
      value = "    "
      @validator.validate_hex.(value).class.should == Left
    end
  end

  describe "when the value contains non-hexidecimal characters" do
    it "should not be valid with alphabet characters" do
      value = "gohguth"
      @validator.validate_hex.(value).class.should == Left
    end

    it "should not be valid with newline characters" do
      value = "abc\nabc"
      @validator.validate_hex.(value).class.should == Left
    end
  end
end
