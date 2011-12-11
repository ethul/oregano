require "spec_helper"

describe Utf8Formatter do
  before do
    @formatter = Object.new
    @formatter.extend Utf8Formatter
  end

  describe "when a string with crlfs is formatted" do
    it "should have the crlfs converted to newlines" do
      value = "a\r\n\r\n"
      expected = "a\n\n"
      @formatter.format_utf8.(value).fold ->_{fail_with "fail"}, ->a {a.should == expected}
    end
  end

  describe "when a string with invalid utf-8 is formatted" do
    it "should replace the invalid characters" do
      value = "\xefa\xbfb\xbdc"
      expected = "\ufffda\ufffdb\ufffdc"
      @formatter.format_utf8.(value).fold ->_{fail_with "fail"}, ->a {a.should == expected}
    end
  end

  describe "when a string with only utf-8 characters is formatted" do
    it "should not change the string" do
      value = "abc"
      expected = "abc"
      @formatter.format_utf8.(value).fold ->_{fail_with "fail"}, ->a {a.should == expected}
    end
  end

  # TODO: ethul, consider all cases from
  # http://www.cl.cam.ac.uk/~mgk25/ucs/examples/UTF-8-test.txt
end
