require "spec_helper"

describe NonEmptyListFormatter do
  before do
    @formatter = Object.new
    @formatter.extend NonEmptyListFormatter
  end

  describe "when a list with empty values is formatted" do
    it "should remove the empty values from the list" do
      value = ["a","b","","c","","d"]
      expected = ["a","b","c","d"]
      @formatter.format_non_empty_list.(value).fold ->_{fail_with "fail"}, ->a {a.should == expected}
    end
  end

  describe "when an empty list formatted" do
    it "should remain an empty list" do
      value = []
      expected = []
      @formatter.format_non_empty_list.(value).fold ->_{fail_with "fail"}, ->a {a.should == expected}
    end
  end

  describe "when nil is formatted" do
    it "should be an error" do
      value = nil
      @formatter.format_non_empty_list.(value).class.should == Left
    end
  end
end
