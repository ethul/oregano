require "spec_helper"

describe Relations::UserCategory do
  before do
    @mock_persist = mock("Persist")
  end

  describe "when a user category relation is saved" do
    before do
      @user = "aaa"
      @category = "bbb"
    end

    it "should persist the category key into the user's categories set" do
      relation = Relations::UserCategory.new @user,@category
      relation.should_receive(:persist).once.and_return(@mock_persist)
      @mock_persist.should_receive(:call).with(/:#{@user}$/,@category).once.and_return(Right.new :right)
      relation.save
    end

    it "should not persist with a nil user" do
      relation = Relations::UserCategory.new nil,@category
      relation.should_not_receive(:persist)
      relation.save
    end

    it "should not persist with an empty user" do
      relation = Relations::UserCategory.new "",@category
      relation.should_not_receive(:persist)
      relation.save
    end

    it "should not persist with a blank user" do
      relation = Relations::UserCategory.new "    ",@category
      relation.should_not_receive(:persist)
      relation.save
    end

    it "should not persist with an empty category" do
      relation = Relations::UserCategory.new @user,""
      relation.should_not_receive(:persist)
      relation.save
    end

    it "should not persist with a nil category" do
      relation = Relations::UserCategory.new @user,nil
      relation.should_not_receive(:persist)
      relation.save
    end

    it "should not persist with a blank category" do
      relation = Relations::UserCategory.new @user,"   "
      relation.should_not_receive(:persist)
      relation.save
    end

    it "should not persist with a non hexadecimal user" do
      relation = Relations::UserCategory.new "$$%ojfeofije",@category
      relation.should_not_receive(:persist)
      relation.save
    end

    it "should not persist with a non hexadecimal category" do
      relation = Relations::UserCategory.new @user,"vvoiejoij"
      relation.should_not_receive(:persist)
      relation.save
    end

    it "should not persist with a hexadecimal category with newlines" do
      relation = Relations::UserCategory.new @user,"aaa\nbbb"
      relation.should_not_receive(:persist)
      relation.save
    end
  end
end
